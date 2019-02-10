#!/bin/bash

LOGIN="login"
USER_BACKUP_DIR=${LOGIN};
EXCLUDE_DIR="/home/${USER_BACKUP_DIR}/dedibackup";

for homedir in $(ls -1d /home/* | grep -Ev "lost\+found"); do
    TAR_FILE="/home/${USER_BACKUP_DIR}/dedibackup/system/home/$(basename ${homedir})_$(date +%Y%m%d).tar.gz"
    echo ${homedir}
    echo ${TAR_FILE}
    tar --posix --exclude=${EXCLUDE_DIR} -cpzf ${TAR_FILE} ${homedir} >/dev/null 2>&1;
    chown $(id -nu ${USER_BACKUP_DIR=}):$(id -ng ${USER_BACKUP_DIR=}) ${TAR_FILE}
    ls -1 "${TAR_FILE%_*}"* | sort -u | head -n-3 | xargs -r rm -v
done

exit 0
