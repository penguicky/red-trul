#!/bin/bash
# This is a wrapper script that will queue up pending runs so that ongoing ones
# must finish before continuing.
set -e

LOCKFILE="/tmp/$(basename "$0").lock"
TIMEOUT=3600
touch "$LOCKFILE"

# Create a file descriptor over the given lockfile.
exec {FD}<>"$LOCKFILE"
echo [.] flock: wait for our turn
if ! flock -x -w $TIMEOUT $FD; then
  echo "Failed to obtain a lock within $TIMEOUT seconds"
  echo "Another instance of $(basename "$0") is probably running."
  exit 1
else
  echo [+] flock: our turn to go!
  "$(dirname "$(realpath "$0")")"/trul.js "$@"
fi
