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

function install_done {
    rm -Rf "$HOME/install.lock"
}

function finalize {
    install_done
    exit $1
}

function lock {
    touch "$MODULEDDEST/$1"
    touch "$MODULED/$1" || echo "WARNING: Failed to create $MODULED/$1"
}

# Tell the health check we are still installing
touch "$HOME/install.lock"

# Install depdendencies if not done already
function module {
if [[ ! -z "$NO_INSTALL" || \
    ( -d "$MODULED" && ! -L "$MODULED" ) || \
    ( -d "$MODULED" &&   -L "$MODULED" && -e "$MODULED/modules.lock" ) || \
    -e "$MODULEDDEST/modules.lock" ]]
then
    echo "INFO: $MODULED (or modules.lock) does exist. Skipping $MANAGER install/"
else
    yarn config set cache-folder "$HOME/yarn"
    ( cd $BIN && ( eval "PATH=$PATH HOST=$HOST $MANAGER install --no-lockfile --modules-folder \"$MODULEDDEST\" $INSTALL_OPTS" ) ) || ( rm -Rf "$MODULEDDEST/*"; finalize 1 )
    lock "modules.lock"
    # chown -R root:root "$MODULEDDEST/"
fi;
}

# Run the dist script, if not done already
function dist {
local UNLINK=0
if [[ ! -z "$NO_DIST" || -e "$MODULEDDEST/dist.lock" ]]
then
    echo "INFO: Skipping $MANAGER dist/"
else
    if [[ ! -d "$MODULED" || ! -L "$MODULED" ]]
    then
        echo "Attempting to create node_modules in bin (grunt can't find tasks otherwise).."
        ( ln -fsn "$MODULEDDEST" "$MODULED" ) || echo "WARNING: Failed mapping $MODULEDDEST to $MODULED"
        UNLINK=1
    fi
    ( PATH="$PATH:$MODULEDDEST/.bin:$MODULED/.bin"; cd $BIN && eval "PATH=$PATH HOST=$HOST $MANAGER run dist $DIST_OPTS" && lock "dist.lock" ) || finalize 1
    if (( UNLINK == 1 ))
    then
        unlink "$MODULED" || echo "WARNING: Failed unlinking $MODULED from $MODULEDDEST"
    fi;
fi;
}

# Run the tests, if not done already
function tests {
if [[ ! -z "$NO_TEST" || -e "$MODULEDDEST/test.lock" ]]
then
    echo "INFO: Skipping $MANAGER test/"
else
    ( PATH="$PATH:$MODULEDDEST/.bin:$MODULED/.bin"; cd $BIN && eval "PATH=$PATH HOST=$HOST $MANAGER run test $TEST_OPTS"  && lock "test.lock" ) || finalize 1
fi;
}

# Execute the prerun steps logged
LOG="$HOME/logs/$HOSTNAME-harness.log"
module 2>&1 | tee -a $LOG
dist   2>&1 | tee -a $LOG
tests  2>&1 | tee -a $LOG

# remove the lock
install_done

# Finally, run the start option
( PATH="$PATH:$MODULEDDEST/.bin:$MODULED/.bin"; ( cd $BIN && eval "PATH=$PATH HOST=$HOST $MANAGER run $NODE_COMMAND -- $NODE_OPTS" ) || exit 1 )

# return normal exit
finalize 0
