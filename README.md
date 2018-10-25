# Resign

Batch script that will scrape the folder it is run in for .ipa files, increment their build number and resigns the app. 

Takes parameters:

 - major | minor | patch - the number to increment
 - Path to new .mobileprovising file to resign the app with

It will then ask for input on which signing profile to use from your machine. WARNING: It will use this same profile for **all** ipa files in the folder. 
