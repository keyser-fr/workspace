#!/usr/bin/env bash

set -e
# set -x # debug mode => equivalent for bash -x command

NUMBER_BACKUP=10

if [[ -z ${DATABASE} || -z ${PASSWORD} ]]; then
    echo -e 'DATABASE and/or PASSWORD not set\n'
    echo -e "Usage: DATABASE='<database>' PASSWORD='<password>' ${0}"
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

exit 0
