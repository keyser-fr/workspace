#!/bin/sh
#
HOST="$1" ; shift
if test $# -gt 1; then
    PORT="$1"
    shift
else
    PORT="1984"
fi
MSG="$1"

( echo "$MSG"; sleep 1 ) | telnet $HOST $PORT 2>&1 >/dev/null | grep -v "closed by foreign host"
