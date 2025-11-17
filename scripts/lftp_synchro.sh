#!/usr/bin/env bash

# set -e
# set -x # debug mode => equivalent for bash -x command

DATE_NOW=$(date +"%F_%T")
SOURCE_DIR=${SOURCE_DIR:-"${HOME}/dedibackup/"}
DEST_DIR=${DEST_DIR:-"/dedibackup"}
# LOG_DIR=${LOG_DIR:-${HOME}/.local/share/lftp/transfer_log} # default directory
LOG_DIR=${LOG_DIR:-${HOME}/var/log"}

$(which lftp) ftp://auto:@dedibackup-dc3.online.net -e "set log:file/xfer ${LOG_DIR}; mirror -e -R ${SOURCE_DIR} ${DEST_DIR}; quit"
RETVAL=${?}

if [[ ${RETVAL} == 0 ]]; then
    echo "[${DATE_NOW}][LFTP] Synchronization OK"
else
    echo "[${DATE_NOW}][LFTP] Synchronization KO"
    exit 1
fi

exit 0
