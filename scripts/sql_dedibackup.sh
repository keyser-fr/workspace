#!/usr/bin/env bash

# set -e
# set -x # debug mode => equivalent for bash -x command

DATE_NOW=$(date +"%F_%T")
SOURCE_DIR=${SOURCE_DIR:-"${HOME}/rescue/sql/sql.free.fr"}
DEST_DIR=${DEST_DIR:-"${HOME}/dedibackup/backup/sql"}

# $(which cp) -r ${SOURCE_DIR} ${DEST_DIR}
$(which rsync) -avz --human-readable --delete ${SOURCE_DIR} ${DEST_DIR}/ #--dry-run
RETVAL=${?}

if [[ ${RETVAL} == 0 ]]; then
    echo "[${DATE_NOW}] Synchronization OK"
else
    echo "[${DATE_NOW}] Synchronization KO"
    exit 1
fi

exit 0
