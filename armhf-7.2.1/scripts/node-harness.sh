#!/usr/bin/env bash

set -eo pipefail

# Get running container's IP
HOST=`hostname --ip-address`

if [ -z "$MANAGER" ]; then
    MANAGER="yarn"
fi;

if [ -z "$NODE_COMMAND" ]; then
    NODE_COMMAND="start"
fi;

# The filder containing the dependencies
BIN="$HOME/bin"
MODULED="$BIN/node_modules"
MODULEDDEST="$HOME/node_modules"

# Install depdendencies if not done already
if [[ ! -z "$NO_INSTALL" || -d "$MODULED" || -e "$MODULEDDEST/modules.lock" ]]
then
    echo "INFO: $MODULED (or modules.lock) does exist. Skipping $MANAGER install/"
else
    yarn config set cache-folder "$HOME/yarn"
    ( cd $BIN && ( eval "HOST=$HOST $MANAGER install --no-lockfile --modules-folder \"$MODULEDDEST\" $INSTALL_OPTS" ) ) || ( rm -Rf "$MODULEDDEST/*"; exit 1 )
    touch "$MODULEDDEST/modules.lock"
    chown -R root:root "$MODULEDDEST/"
fi;

# Run the dist script, if not done already
if [[ ! -z "$NO_DIST" || -e "$MODULEDDEST/dist.lock" ]]
then
    echo "INFO: Skipping $MANAGER dist/"
else
    ( PATH="$PATH:$MODULEDDEST/.bin:$MODULED/.bin"; cd $BIN && eval "HOST=$HOST $MANAGER run dist $DIST_OPTS" ) && touch "$MODULEDDEST/dist.lock"
fi;

# Run the tests, if not done already
if [[ ! -z "$NO_TEST" || -e "$MODULEDDEST/test.lock" ]]
then
    echo "INFO: Skipping $MANAGER test/"
else
    ( PATH="$PATH:$MODULEDDEST/.bin:$MODULED/.bin"; cd $BIN && eval "HOST=$HOST $MANAGER run test $TEST_OPTS" ) && touch "$MODULEDDEST/test.lock"
fi;

# Finally, run the start option
( PATH="$PATH:$MODULEDDEST/.bin:$MODULED/.bin"; ( cd $BIN && eval "HOST=$HOST $MANAGER run $NODE_COMMAND -- $NODE_OPTS" ) || exit 1 )

# return normal exit
exit 0
