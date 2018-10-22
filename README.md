# Resign

Batch script that will scrape the folder it is run in for .ipa files, increment their build number and resigns the app. 

Takes parameters:

 - major | minor | patch - the number to increment
 - [Optional] Signing identity key - the HEX code of the signing identity to use.

If you don't supply the signing key as a parameter, it will ask you for it during the process. 
