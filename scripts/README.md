# For backup on dedibackup
Debut du crontab

```{r, engine='bash', count_lines}
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
#
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command

MAILTO=""
```

Dans la crontab du user ajouter les lignes suivantes :

```{r, engine='bash', count_lines}
# Backup sur dedibackup
0 22 * * * lftp ftp://auto:@dedibackup-dc3.online.net -e "mirror -e -R ~/dedibackup/ /dedibackup; quit"
```

# sql_dump usage
Dans la crontab du user ajouter les lignes suivantes :

```{r, engine='bash', count_lines}
# Backup databases on sql.free.fr
0 1 * * * DATABASE='database_name1' PASSWORD='password1' ${HOME}/bin/sql_dump.sh
10 1 * * * DATABASE='database_name2' PASSWORD='password2' ${HOME}/bin/sql_dump.sh
```
