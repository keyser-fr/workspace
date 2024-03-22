#!/usr/bin/env bash

# set -e
# set -x # debug mode => equivalent for bash -x command

DATABASE=${DATABASE:-${1}}
NUMBER_BACKUP=10
DEST_DIR="rescue/sql/sql.free.fr"

function usage() {
    echo "Usage: ${0} <database>"
}

if [[ -z ${DATABASE} ]]; then
    echo 'DATABASE not set'
    usage
    exit 1
fi

GITLAB_TOKEN=$(grep -Ew "gitlab_token" ${HOME}/.git-credentials | awk '{print $NF}')
GITLAB_TOKEN_THRESHOLD_ALERT=604800
# Add .ansible_vaultkey file
ANSIBLE_VAULTKEY_FILE=${ANSIBLE_VAULTKEY_FILE:-.ansible_vaultkey}
touch ${HOME}/${ANSIBLE_VAULTKEY_FILE}
EXPIRED_AT=$(curl --silent --request GET --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "https://gitlab.com/api/v4/personal_access_tokens" | jq -r '.[].expires_at')
EXPIRED_AT_TS=$(date --date="${EXPIRED_AT}" +"%s")
NOW_DATE_TS=$(date --date="now" +"%s")

SUP_FILE=${DEST_DIR}/gitlab_token.expired
# Handle gitlab_token expiration
if (( $(( ${EXPIRED_AT_TS} - ${NOW_DATE_TS} )) <= 0 )); then
    echo "Gitlab Token expired"
    exit 1
elif (( $(( ${EXPIRED_AT_TS} - ${NOW_DATE_TS} )) <= ${GITLAB_TOKEN_THRESHOLD_ALERT} )); then
    # Add file for supervision
    if [[ ! -f ${SUP_FILE} ]]; then
	touch ${SUP_FILE}
    fi
else
    if [[ -f ${SUP_FILE} ]]; then
	rm ${SUP_FILE}
    fi
fi

curl --silent --request GET --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "https://gitlab.com/api/v4/groups/8268726/variables/_ansible_vaultkey" | jq -r '.value' > ${HOME}/${ANSIBLE_VAULTKEY_FILE}
chmod 400 ${HOME}/${ANSIBLE_VAULTKEY_FILE}
PASSWORD=${PASSWORD:-$(ansible-vault view --vault-password-file=${HOME}/${ANSIBLE_VAULTKEY_FILE} ${HOME}/${DEST_DIR}/sql_vaulted.yaml | grep "SQL_PASSWORD:" | awk '{print $NF}' | tr -d "'")}

if [[ -z ${PASSWORD} ]]; then
    echo 'PASSWORD not set'
    usage
    exit 1
fi

backup_dir="${HOME}/${DEST_DIR}/${DATABASE}"

rm -f curl.headers
rm -f backup.php

curl -s -S -O -D curl.headers -d "login=$DATABASE&password=$PASSWORD&check=1&all=1" http://sql.free.fr/backup.php

if [ $? -ne 0 ]; then
    echo "Erreur curl" >&2
    exit 1
else
    echo "Backup MySQL for ${DATABASE} OK"
fi

grep -q "HTTP/1.1 200 OK" curl.headers
if [ $? -eq 0 ]; then
    grep -q "Content-Disposition: attachment" curl.headers
    if [ $? -eq 0 ]
    then
	filename=$(grep "Content-Disposition: attachment" curl.headers | sed -e 's/.*filename="//;s/";.*$//')
	mv backup.php ${backup_dir}/backup_mysql_${filename}
	echo "Saved in ${backup_dir}/backup_mysql_${filename}"
    fi
    ls -1 ${backup_dir}/backup_mysql_*.gz | sort -u | head -n-${NUMBER_BACKUP} | xargs -r rm -v
else
    echo -n "Error : " >&2
    grep "HTTP/1.1 " curl.headers >&2
    exit 1
fi

rm -f curl.headers
rm -f backup.php

# Remove .ansible_vaultkey file
find ${HOME} -type f -name "${ANSIBLE_VAULTKEY_FILE}" -delete

exit 0
