#!/usr/bin/env bash

set -e
# set -x # debug mode => equivalent for bash -x command

GITLAB_URL="https://gitlab.com"
GITLAB_API="api"
GITLAB_API_VERSION="v4"
GITLAB_API_URL="${GITLAB_URL}/${GITLAB_API}/${GITLAB_API_VERSION}"
GITLAB_TOKEN_FILE=${HOME}/.git-credentials
GITLAB_TOKEN=$(grep -Ew "gitlab_token" ${GITLAB_TOKEN_FILE} | awk '{print $NF}')
GITLAB_TOKEN_THRESHOLD_ALERT=7200 # 7200 (2 day) & 604800 (7 days)
GITLAB_ACCESS_INFO=$(curl --silent --request GET --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/personal_access_tokens?revoked=false")
GITLAB_TOKEN_EXPIRED_AT=$(jq -r '.[].expires_at' <<< ${GITLAB_ACCESS_INFO})
GITLAB_TOKEN_EXPIRED_AT_TS=$(date --date="${GITLAB_TOKEN_EXPIRED_AT}" +"%s")
NOW_DATE_TS=$(date --date="now" +"%s")
DEST_DIR="${HOME}/rescue/sql/sql.free.fr"
SUP_FILE=${DEST_DIR}/gitlab_token.expired

# Handle gitlab_token expiration
if (( $(( ${GITLAB_TOKEN_EXPIRED_AT_TS} - ${NOW_DATE_TS} )) <= 0 )); then
    echo "Gitlab Token expired"
    # Add file for supervision
    if [[ ! -f ${SUP_FILE} ]]; then
	touch ${SUP_FILE}
    fi
    exit 1
elif (( $(( ${GITLAB_TOKEN_EXPIRED_AT_TS} - ${NOW_DATE_TS} )) <= ${GITLAB_TOKEN_THRESHOLD_ALERT} )); then
    # Renew token (rotate)
    GITLAB_TOKEN_ID=$(jq -r '.[].id' <<< ${GITLAB_ACCESS_INFO})
    GITLAB_TOKEN_ROTATE=$(curl --silent --request POST --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}"  "${GITLAB_API_URL}/personal_access_tokens/${GITLAB_TOKEN_ID}/rotate")
    GITLAB_TOKEN_RENEW=$(jq -r '.token' <<< ${GITLAB_TOKEN_ROTATE})
    chmod 600 ${GITLAB_TOKEN_FILE}
    echo "gitlab_token = ${GITLAB_TOKEN_RENEW}" > ${GITLAB_TOKEN_FILE}
    chmod 400 ${GITLAB_TOKEN_FILE}
else
    # Remove file for supervision
    if [[ -f ${SUP_FILE} ]]; then
	rm ${SUP_FILE}
    fi
fi

exit 0
