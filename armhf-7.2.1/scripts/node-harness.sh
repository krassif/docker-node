#!/usr/bin/env bash

# Get running container's IP
HOST=`hostname --ip-address`

if [ -z "$MANAGER" ]; then
    MANAGER="yarn"
fi;

# The filder containing the dependencies
BIN="./bin" 
MODULED="$BIN/node_modules"
MODULEDDEST="./node_modules"

# Install depdendencies if not done already
if [[ ! -z "$NO_INSTALL" && -d "$MODULED" && -e "$MODULEDDEST/modules.lock" ]]
then
    echo "INFO: $MODULED does exist. Skipping $MANAGER install/"
else
    ( cd $BIN && ( eval "HOST=$HOST $MANAGER install --no-lockfile --modules-folder \".$MODULEDDEST\" $INSTALL_OPTS" || rm -Rf ".$MODULEDDEST/*" || exit 1 ) )
    touch "$MODULEDDEST/modules.lock"
fi;

# Run the dist script, if not done already
if [[ ! -z "$NO_DIST" && -e "$MODULEDDEST/dist.lock" ]]
then
    echo "INFO: Skipping $MANAGER dist/"
else
    ( cd $BIN && eval "HOST=$HOST $MANAGER run dist $DIST_OPTS" ) && touch "$MODULEDDEST/dist.lock"
fi;

# Run the tests, if not done already
if [[ ! -z "$NO_TEST" && -e "$MODULEDDEST/test.lock" ]]
then
    echo "INFO: Skipping $MANAGER test/"
else
    ( cd $BIN && eval "HOST=$HOST $MANAGER run test $TEST_OPTS" ) && touch "$MODULEDDEST/test.lock"
fi;

# Finally, run the start option
( cd $BIN && eval "HOST=$HOST node $NODE_OPTS" || exit 1 )

# return normal exit
exit 0
