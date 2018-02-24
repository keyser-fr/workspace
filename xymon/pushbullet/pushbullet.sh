#!/bin/bash

# Link of environment variables for xymon alerts : http://xymon.sourceforge.net/xymon/help/xymon-alerts.html

# The full list of environment variables provided to scripts are as follows:
#     BBCOLORLEVEL The current color of the status
#     BBALPHAMSG The full text of the status log triggering the alert
#     ACKCODE The "cookie" that can be used to acknowledge the alert
#     RCPT The recipient, from the SCRIPT entry
#     BBHOSTNAME The name of the host that the alert is about
#     MACHIP The IP-address of the host that has a problem
#     BBSVCNAME The name of the service that the alert is about
#     BBSVCNUM The numeric code for the service. From SVCCODES definition.
#     BBHOSTSVC HOSTNAME.SERVICE that the alert is about.
#     BBHOSTSVCCOMMAS As BBHOSTSVC, but dots in the hostname replaced with commas
#     BBNUMERIC A 22-digit number made by BBSVCNUM, MACHIP and ACKCODE.
#     RECOVERED Is "1" if the service has recovered.
#     DOWNSECS Number of seconds the service has been down.
#     DOWNSECSMSG When recovered, holds the text "Event duration : N" where N is the DOWNSECS value.

XYMON_PROTOCOL='https' # 'http'
XYMON_FQDN='xymon.domain.fqdn' # $(hostname -f)
TOKENPUSHBULLET=""
CACHEDIR=/var/cache/xymon
CACHEFILE=pushbullet

if [ ! -d "${CACHEDIR}" ]; then
    mkdir ${CACHEDIR}
fi


if [ ! -f "${CACHEDIR}/${CACHEFILE}" ]; then
    touch ${CACHEDIR}/${CACHEFILE}
fi


# Si il y a un token, on le dismiss
token=$(grep "${BBHOSTNAME};${BBSVCNAME};" ${CACHEDIR}/${CACHEFILE} | awk -F ";" '{print $3}')

if [ "x${token}" != "x" ]; then
    curl --silent --header "Access-Token: ${TOKENPUSHBULLET}" \
	 --request DELETE \
	 https://api.pushbullet.com/v2/pushes/${token} 2>&1 > /dev/null

    sed -i "/^${BBHOSTNAME};${BBSVCNAME};/d" ${CACHEDIR}/${CACHEFILE}
    sleep 1
fi

# Si on est en recovered on envoie pas de push
if [ "${RECOVERED}" == "0" ]; then
    returnval=$(curl --silent --header "Access-Token: ${TOKENPUSHBULLET}" \
		     --header 'Content-Type: application/json' \
		     --data-binary '{"body": "", "title": "['${BBCOLORLEVEL}'] '${BBHOSTNAME}' - '${BBSVCNAME}'", "type": "link", "url": "'${XYMON_PROTOCOL}'://'${XYMON_FQDN}'/xymon-cgi/svcstatus.sh?HOST='${BBHOSTNAME}'&SERVICE='${BBSVCNAME}'", "dismissable": true}' \
		     --request POST \
		     https://api.pushbullet.com/v2/pushes)

    token=$(echo ${returnval} | sed -e 's/^.\+"iden":"\([^"]\+\)".\+$/\1/')
    echo "${BBHOSTNAME};${BBSVCNAME};${token};" >> ${CACHEDIR}/${CACHEFILE}
fi
