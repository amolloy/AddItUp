#!/bin/bash

REVISION_NO=`bzr revno`

echo REVISION_NO=${REVISION_NO} > revision.xcconfig

APPBASENAME=iAdder

function checkExitCode
{
    if [ "$?" != "0" ]; then
	exit $?
    fi
}

security list-keychains -s /Users/amolloy/Library/Keychains/iPhone.keychain /Users/amolloy/Library/Keychains/login.keychain
checkExitCode

security unlock-keychain -p c0rny /Users/amolloy/Library/Keychains/iPhone.keychain
checkExitCode

/usr/bin/xcodebuild -project ${APPBASENAME}.xcodeproj -configuration $1 -sdk /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.0.sdk
checkExitCode

if [ $1 = "Ad-Hoc" ]; then
    if [ -e AdHoc-ipa/Payload/${APPBASENAME}.app ]; then
	rm -r AdHoc-ipa/Payload/${APPBASENAME}.app
	checkExitCode    
    fi

    cp -r build/${1}-iphoneos/${APPBASENAME}.app AdHoc-ipa/Payload
    checkExitCode
    
    chmod -R 755 AdHoc-ipa/Payload
    checkExitCode

    cd AdHoc-ipa
    checkExitCode

    if [ -e ../build/${1}-iphoneos/${APPBASENAME}.ipa ]; then
	rm ../build/${1}-iphoneos/${APPBASENAME}.ipa
	checkExitCode
    fi

    zip -r ../build/${1}-iphoneos/${APPBASENAME}.ipa iTunesArtwork Payload
    checkExitCode
else
    cd build/${1}-iphoneos
    checkExitCode
    
    if [ -e ${APPBASENAME}.zip ]; then
	rm ${APPBASENAME}.zip
    fi

    zip -r ${APPBASENAME}.zip ${APPBASENAME}.app
    checkExitCode
fi

