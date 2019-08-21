#!/bin/bash

EXCLUDE_DIR="${HOME}/dedibackup"
DEDIBACKUP_HOMEDIR="dedibackup/system/home"
NUMBER_BACKUP=3

for homedir in $(ls -1d /home/* | grep -Ev "lost\+found"); do
    TAR_FILE="${HOME}/${DEDIBACKUP_HOMEDIR}/$(basename ${homedir})_$(date +%Y%m%d).tar.gz"
    echo ${homedir}
    echo ${TAR_FILE}
    tar --posix --exclude=${EXCLUDE_DIR} -cpzf ${TAR_FILE} ${homedir} >/dev/null 2>&1;
    chown $(id -nu ${USER}):$(id -ng ${USER}) ${TAR_FILE}
    ls -1 "${TAR_FILE%_*}"* | sort -u | head -n-${NUMBER_BACKUP} | xargs -r rm -v
done

exit 0

