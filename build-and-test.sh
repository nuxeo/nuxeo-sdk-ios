#!/bin/bash

#set -e

HERE=$(cd $(dirname $0); pwd -P)
NX_INT=$HERE/download/nuxeo-integration
XCBUILD=${XCBUILD:-xcodebuild}

# Cleaning
rm -rf download nuxeo tomcat junit-result.xml || exit 1

# Cloning integration-release
git clone https://github.com/nuxeo/integration-scripts $NX_INT

# Loading integration-lib.sh
. $NX_INT/integration-lib.sh

$NX_INT/download.sh

# Make wizard done.
echo "nuxeo.wizard.done=true" >> tomcat/bin/nuxeo.conf
echo "init" >> tomcat/nxserver/data/installAfterRestart.log
start_server $HERE/tomcat 127.0.0.1

# Prepare CocoaPod workspace
./prepare-pod.sh

echo "Build: `which $XCBUILD`"
$XCBUILD -reporter junit:junit-result.xml -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6s' -workspace NuxeoSDK/NuxeoSDK.xcworkspace -scheme NuxeoSDK clean test
EXIT_CODE=$?

stop_server

exit $EXIT_CODE
