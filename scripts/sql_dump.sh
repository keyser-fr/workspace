#!/usr/bin/env bash

set -e
# set -x # debug mode => equivalent for bash -x command

DATABASE=${DATABASE:-${1}}
NUMBER_BACKUP=10

function usage() {
    echo "Usage: ${0} <database>"
}

if [[ -z ${DATABASE} ]]; then
    echo 'DATABASE not set'
    usage
    exit 1
fi

GITLAB_TOKEN=$(grep -Ew "gitlab_token" ${HOME}/.git-credentials | awk '{print $NF}')
# Add .ansible_vaultkey file
ANSIBLE_VAULTKEY_FILE=${ANSIBLE_VAULTKEY_FILE:-.ansible_vaultkey}
touch ${HOME}/${ANSIBLE_VAULTKEY_FILE}
curl --silent --request GET --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "https://gitlab.com/api/v4/groups/8268726/variables/_ansible_vaultkey" | jq -r '.value' > ${HOME}/${ANSIBLE_VAULTKEY_FILE}
chmod 400 ${HOME}/${ANSIBLE_VAULTKEY_FILE}
PASSWORD=${PASSWORD:-$(ansible-vault view --vault-password-file=${HOME}/${ANSIBLE_VAULTKEY_FILE} ${HOME}/rescue/sql/sql.free.fr/sql_vaulted.yaml | grep "SQL_PASSWORD:" | awk '{print $NF}' | tr -d "'")}

if [[ -z ${PASSWORD} ]]; then
    echo 'PASSWORD not set'
    usage
    exit 1
fi

backup_dir="${HOME}/rescue/sql/sql.free.fr/${DATABASE}"

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
