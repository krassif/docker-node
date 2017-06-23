#!/usr/bin/env bash

# Get running container's IP
HOST=`hostname --ip-address`

# The filder containing the dependencies 
MODULED="./node_modules";

# Install depdendencies if not done already
if [ -d "$MODULED" ]
then
    echo "INFO: $MODULED does exist. Skipping yarn install/"
else
    eval "HOST=$HOST yarn install $INSTALL_OPTS" || rm -Rf $MODULED || exit 1
fi;

# Run the dist script, if not done already
if [ -e "$MODULED/dist.lock" ]
then
    echo "INFO: Skipping yarn dist/"
else
    eval "HOST=$HOST yarn run dist $DIST_OPTS" && touch "$MODULED/dist.lock"
fi;

# Run the tests, if not done already
if [ -e "$MODULED/test.lock" ]
then
    echo "INFO: Skipping yarn test/"
else
    eval "HOST=$HOST yarn run test $TEST_OPTS" && touch "$MODULED/test.lock"
fi;

# Finally, run the start option
eval "HOST=$HOST node $NODE_OPTS" || exit 1

# return normal exit
exit 0
