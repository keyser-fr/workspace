#!/bin/bash

# Declaration globale
datetime=$(date "+%Y-%m-%d %H:%M:%S")

# Gestion inotify
ts3_directory='/opt/teamspeak/teamspeak/logs'
inotify_file=$(ls -1tr ${ts3_directory} | tail -1)
inotify_filepath=${ts3_directory}/${inotify_file}
# echo ${inotify_filepath}
# exit

# Recuperation des infos des logs
loginfo=$(grep -E "client[[:space:]].*connected" ${inotify_filepath} | tail -1 | awk '{ print $1" "$2" "$6" "$7 }')
dateinfo=$(echo "${loginfo}" | awk '{ print $1 }')
hourinfo=$(echo "${loginfo}" | awk '{ print $2 }' | sed 's/\..*|INFO//g')
statusinfo=$(echo "${loginfo}" | awk '{ print $3 }')
userinfo=$(echo "${loginfo}" | awk '{ print $4 }')

# Gestion de l'envoi de mails
email_destination="<email_address>"
message="${statusinfo} de ${userinfo}"

# Main du script
# Enabled send mail
# cmd=$(echo "[${dateinfo} ${hourinfo}] ${message}" | mail -s "[TS3] ${userinfo} ${statusinfo}" ${email_destination})

# Enabled log
LOGIN="login"
# echo ${cmd} >> "/home/${LOGIN}/log/ts3_inotify.log"

# Print command
# echo "${cmd}"
# echo "echo \"[${dateinfo} ${hourinfo}] ${message}\" | mail -s \"[TS3] ${userinfo} ${statusinfo}\" ${email_destination}"

exit 0
