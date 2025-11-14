#!/usr/bin/env bash

set -e
# set -x # debug mode => equivalent for bash -x command

# Variables
NOW_DATE=$(date --date="now" "+%F %T")
NOW_DATE_TS=$(date --date="now" +"%s")
DATE_30_DAYS_EXPIRATION=$(date --date="now +30 days" "+%Y-%m-%d")
DEST_DIR=${DEST_DIR:-"${HOME}/dedibackup/backup/sql/sql.free.fr"}
SUP_FILE=${DEST_DIR}/gitlab_token.expired
GITLAB_URL="https://gitlab.com"
GITLAB_API="api"
GITLAB_API_VERSION="v4"
GITLAB_API_URL="${GITLAB_URL}/${GITLAB_API}/${GITLAB_API_VERSION}"
GITLAB_TOKEN_FILE=${HOME}/.git-credentials
GITLAB_TOKEN=$(grep -Ew "gitlab_token" ${GITLAB_TOKEN_FILE} | awk '{print $NF}')
GITLAB_TOKEN_THRESHOLD_ALERT=172800 # 172800 (2 days) & 604800 (7 days)
GITLAB_ACCESS_INFO=$(curl --silent --request GET --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_API_URL}/personal_access_tokens?state=active")
if [[ ${GITLAB_ACCESS_INFO} =~ "invalid_token" ]]; then
    # echo "[${NOW_DATE}]Invalid Token"
    touch ${SUP_FILE}
    exit 1
fi
GITLAB_TOKEN_EXPIRED_AT=$(jq -r '.[].expires_at' <<< ${GITLAB_ACCESS_INFO})
GITLAB_TOKEN_EXPIRED_AT_TS=$(date --date="${GITLAB_TOKEN_EXPIRED_AT}" +"%s")

# Handle gitlab_token expiration
if (( $(( ${GITLAB_TOKEN_EXPIRED_AT_TS} - ${NOW_DATE_TS} )) < ${GITLAB_TOKEN_THRESHOLD_ALERT} )); then
    # Renew token (rotate)
    echo "[${NOW_DATE}] Renew token"
    GITLAB_TOKEN_ID=$(jq -r ".[] | select(.expires_at == \"${GITLAB_TOKEN_EXPIRED_AT}\") .id" <<< ${GITLAB_ACCESS_INFO})
    GITLAB_TOKEN_ROTATE=$(curl --silent --request POST --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}"  "${GITLAB_API_URL}/personal_access_tokens/${GITLAB_TOKEN_ID}/rotate?expires_at=${DATE_30_DAYS_EXPIRATION}")
    GITLAB_TOKEN_RENEW=$(jq -r '.token' <<< ${GITLAB_TOKEN_ROTATE})
    chmod 600 ${GITLAB_TOKEN_FILE}
    echo "gitlab_token = ${GITLAB_TOKEN_RENEW}" > ${GITLAB_TOKEN_FILE}
    chmod 400 ${GITLAB_TOKEN_FILE}
elif (( $(( ${GITLAB_TOKEN_EXPIRED_AT_TS} - ${NOW_DATE_TS} )) < 0 )); then
    echo "[${NOW_DATE}] Gitlab Token expired"
    # Add file for supervision
    if [[ ! -f ${SUP_FILE} ]]; then
	touch ${SUP_FILE}
    fi
    exit 1
else
    # Remove file for supervision
    if [[ -f ${SUP_FILE} ]]; then
	rm -f ${SUP_FILE}
	# echo "[${NOW_DATE}] Remove file (Xymon event)"
    fi
fi

exit 0
