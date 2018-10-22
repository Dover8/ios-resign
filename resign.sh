if [ -z "$1" ] #check we are passed an arg
then
    echo "No argument supplied. Choose major : minor : patch for version increment"
    exit 1
fi

for i in *.ipa; do
    [ -f "$i" ] || break
    echo "Parsing app $i"
    unzip -q -o $i #unzip the file
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

    #repackage the app
    /usr/libexec/PlistBuddy -c "Set CFBundleVersion ${bundleVersion}" Payload/*.app/Info.plist
    zip -qr $i Payload
    rm -rf Payload
    #resign the app
    fastlane sigh resign $i
done


