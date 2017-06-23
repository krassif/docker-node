#!/usr/bin/env bash

# Get running container's IP
HOST=`hostname --ip-address`

if [ -z "$MANAGER" ]; then
    MANAGER="yarn"
fi;

# The filder containing the dependencies 
MODULED="./node_modules";

# Install depdendencies if not done already
if [ -d "$MODULED" ]
then
    echo "INFO: $MODULED does exist. Skipping $MANAGER install/"
else
    eval "HOST=$HOST $MANAGER install $INSTALL_OPTS" || rm -Rf $MODULED || exit 1
fi;

# Run the dist script, if not done already
if [ -e "$MODULED/dist.lock" ]
then
    echo "INFO: Skipping $MANAGER dist/"
else
    eval "HOST=$HOST $MANAGER run dist $DIST_OPTS" && touch "$MODULED/dist.lock"
fi;

# Run the tests, if not done already
if [ -e "$MODULED/test.lock" ]
then
    echo "INFO: Skipping $MANAGER test/"
else
    eval "HOST=$HOST $MANAGER run test $TEST_OPTS" && touch "$MODULED/test.lock"
fi;

# Finally, run the start option
eval "HOST=$HOST node $NODE_OPTS" || exit 1

# return normal exit
exit 0
