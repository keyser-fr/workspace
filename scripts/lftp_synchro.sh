#!/usr/bin/env bash

# set -e
# set -x # debug mode => equivalent for bash -x command

DATE_NOW=$(date +"%F_%T")
SOURCE_DIR=${SOURCE_DIR:-"${HOME}/dedibackup/"}
DEST_DIR=${DEST_DIR:-"/dedibackup"}
# LOG_DIR=${LOG_DIR:-"${HOME}/.local/share/lftp"} # default directory
# LOGFILE=${LOGFILE:-"${LOG_DIR}/transfer_log"} # default file
LOG_DIR=${LOG_DIR:-"${HOME}/var/log"}
LOGFILE=${LOGFILE:-"${LOG_DIR}/lftp_transfer.log"}

$(which lftp) ftp://auto:@dedibackup-dc3.online.net -e "set log:file/xfer ${LOGFILE}; mirror -e -R ${SOURCE_DIR} ${DEST_DIR}; quit"
RETVAL=${?}

if [[ ${RETVAL} == 0 ]]; then
    echo "[${DATE_NOW}][LFTP] Synchronization OK"
else
    echo "[${DATE_NOW}][LFTP] Synchronization KO"
    exit 1
fi

exit 0
