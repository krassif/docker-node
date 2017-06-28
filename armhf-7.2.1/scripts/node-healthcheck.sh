#!/bin/bash

set -eo pipefail

# makes sense sending the ip:port to the health checkers
HOST="$(hostname --ip-address || echo '127.0.0.1')"

# run a basic check
if [ ! -z "$PORT" ]; then
    curl --fail --max-time 1 "http://$HOST:$PORT/" || exit 1;
fi;

# look for additional, on the container volumes health check scripts
HEALTHD="./var/health";

if [ -d "$HEALTHD" ]
then
    for f in `find "$HEALTHD" -type f -perm /a+x`
        do eval "HOST=\"$HOST\" PORT=\"$PORT\" \"$f\"" || exit 1
    done;
fi;

exit 0
