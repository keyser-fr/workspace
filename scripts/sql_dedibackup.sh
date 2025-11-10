#!/usr/bin/env bash

# set -e
# set -x # debug mode => equivalent for bash -x command

DEST_DIR="${HOME}/rescue/sql/sql.free.fr"

$(which cp) -r ${DEST_DIR} ${HOME}/dedibackup/mysql/

exit 0
