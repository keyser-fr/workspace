#!/bin/bash

if [[ -z $1 ]]; then
    DISTRIB=$(cat /etc/issue | head -n 1);
    if [[ ${DISTRIB} =~ 'Ubuntu' ]]; then
	WWW_ACCESS_PATH='/var/log/apache2/access.log';
    elif [[ ${DISTRIB} =~ 'CentOS' ]]; then
	WWW_ACCESS_PATH='/var/log/httpd/access_log';
    else
	echo 'Unknown distrib';
	exit 255;
    fi
else
    WWW_ACCESS_PATH=$1
fi

ip_list=$(grep -Ev "82.224.157.186|internal dummy connection" ${WWW_ACCESS_PATH} | awk '{print $1}' | sort | uniq);
ip_array=(${ip_list});

# Host sur les IPs
for i in $(seq ${#ip_array[*]}); do
    # echo ${ip_array[$i-1]};
    host ${ip_array[$i-1]};
done
