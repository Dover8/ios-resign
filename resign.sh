if [ -z "$1" ] #check we are passed an arg
then
    echo "No argument supplied. Choose major : minor : patch for version increment"
    exit 1
fi
if [[ "$1" != "major" && "$1" != "minor" && "$1" != "patch" ]]
then
    echo "Parameter 1 should be major | minor | patch to indicate how to increment the build number"
    exit 1
fi

#ask for the signing identity to use
security find-identity -v -p codesigning
echo "Please select which codesign profile to use. Input the name (i.e 'iPhone Developer: Soluis Technologies Ltd' without the ID)."
read signingID

for i in *.ipa; do
    [ -f "$i" ] || break
    echo "Parsing app $i"
    unzip -q -o $i #unzip the file
    rm -rf Payload/*.app/_CodeSignature

    bundleVersion=$(/usr/libexec/PlistBuddy -c 'Print CFBundleVersion' Payload/*.app/Info.plist) #final the bundle version

    #read it into values
    IFS="." read major minor patch <<< "$bundleVersion"

    if [ -z "$major" ]
    then
        major=0
    fi

    if [ -z "$minor" ]
    then
        minor=0
    fi

    if [ -z "$patch" ]
    then
        patch=0
    fi

    echo "Current version: $bundleVersion"

    #increment appropriate value
    component=$1
    if [[ "$component" = 'major' ]]; then
        major=$((major + 1))
        minor=0
        patch=0
    elif [[ "$component" = 'minor' ]]; then
        minor=$((minor + 1))
        patch=0
    elif [[ "$component" = 'patch' ]]; then
        patch=$((patch + 1))
    fi
    bundleVersion="${major}.${minor}.${patch}"

    echo "App $i incremented to $bundleVersion"

    #write new version number
    /usr/libexec/PlistBuddy -c "Set CFBundleVersion ${bundleVersion}" Payload/*.app/Info.plist

    #do codesigning
    cd Payload/
    codesign -d --entitlements - *.app > entitlements.plist
    cd ..
    mv Payload/entitlements.plist entitlements.plist

    codesign -f -s "${signingID}" '--entitlements' 'entitlements.plist' Payload/*.app

    #repackage
    zip -qr $i Payload

    #clean up, aisle $i
    rm -rf Payload
    rm entitlements.plist
done


