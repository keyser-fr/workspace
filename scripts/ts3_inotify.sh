#!/bin/bash

# Declaration globale
datetime=$(date "+%Y-%m-%d %H:%M:%S")

# Gestion inotify
ts3_directory='/opt/teamspeak/teamspeak/logs'
inotify_file=$(ls -1tr ${ts3_directory} | tail -1 | sed 's/_0.log/_1.log/')
inotify_filepath=${ts3_directory}/${inotify_file}

# Recuperation des infos des logs
loginfo=$(grep -E "client[[:space:]].*connected" ${inotify_filepath} | tail -1 | awk '{ print $1" "$2" "$6" "$7 }')
dateinfo=$(echo "${loginfo}" | awk '{ print $1 }')
hourinfo=$(echo "${loginfo}" | awk '{ print $2 }' | sed 's/\..*|INFO//g')
statusinfo=$(echo "${loginfo}" | awk '{ print $3 }')
userinfo=$(echo "${loginfo}" | awk '{ print $4 }')

# Gestion de l'envoi de mails
LOGIN="login"
email_destination="email_address"
message="${statusinfo} de ${userinfo}"
inotify_cmd=$(echo "/opt/teamspeak/teamspeak/logs IN_CREATE /home/${LOGIN}>/scripts/ts3_inotify.sh" > /var/spool/incron/${LOGIN})
cmd=$(echo "${inotify_filepath} IN_MODIFY /home/${LOGIN}/scripts/ts3_mail.sh" >> /var/spool/incron/${LOGIN})

# Main du script
# echo ${cmd} >> "/home/${LOGIN}/var/log/ts3_inotify.log"

exit 0
