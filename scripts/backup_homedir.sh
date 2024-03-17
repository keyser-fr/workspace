e#!/usr/bin/env bash

set -e

EXCLUDE_IGNORE_FILE="*~"
EXCLUDE_FILE="${HOME}/.ansible_vaultkey"
EXCLUDE_DIR="${HOME}/dedibackup"
DEDIBACKUP_HOMEDIR="dedibackup/system/home"
NUMBER_BACKUP=3

function usage() {
    echo "${0} <homedir_name>"
}

if [[ ! -z ${1} ]]; then
    homedir_list=$(ls -1d /home/${1} | grep -Ev "lost\+found")
else
    homedir_list=$(ls -1d /home/* | grep -Ev "lost\+found")
fi

for homedir in ${homedir_list}; do
    TAR_FILE="${HOME}/${DEDIBACKUP_HOMEDIR}/$(basename ${homedir})_$(date +%Y%m%d_%H%M%S).tar.gz"
    echo ${homedir}
    echo ${TAR_FILE}
    tar --posix --exclude=${EXCLUDE_DIR} --exclude=${EXCLUDE_FILE} --exclude=${EXCLUDE_IGNORE_FILE} -cpzf ${TAR_FILE} ${homedir} >/dev/null 2>&1;
    chown $(id -nu ${USER}):$(id -ng ${USER}) ${TAR_FILE}
    ls -1 ${TAR_FILE%_*_*}*.tar.gz | sort -u | head -n-${NUMBER_BACKUP} | xargs -r rm -v
done

exit 0
