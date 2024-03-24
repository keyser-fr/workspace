#!/usr/bin/env bash

set -e
# set -x # debug mode => equivalent for bash -x command

DEST_DIR="rescue/sql/sql.free.fr"
GITLAB_TOKEN=$(grep -Ew "gitlab_token" ${HOME}/.git-credentials | awk '{print $NF}')
GITLAB_TOKEN_THRESHOLD_ALERT=604800
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

exit 0
