# Examples for alerting

For usage, in alerts.cfg file, add following sentences :

```bash
HOST=%
	SCRIPT /usr/local/bin/pushbullet.sh	pushbullet	DURATION>15m	SERVICE=disk	REPEAT=4h	RECOVERED	COLOR=yellow,red,purple		TIME=*:0930:2130
	SCRIPT /usr/local/bin/pushbullet.sh	pushbullet	DURATION>15m	SERVICE=procs	REPEAT=4h	RECOVERED	COLOR=yellow,red,purple		TIME=*:0930:2130
```

# For test API pushbullet use curl command :

```bash
TOKENPUSHBULLET=''
XYMON_PROTOCOL='https' # 'http'
XYMON_FQDN='xymon.hostname.fqdn' # $(hostname -f)
curl --header "Access-Token: ${TOKENPUSHBULLET}" --header 'Content-Type: application/json' --data-binary '{"body": "", "title": "['RED'] 'TEST' - 'SONDE'", "type": "link", "url": "'${XYMON_PROTOCOL}'://'${XYMON_FQDN}'/xymon-cgi/svcstatus.sh?HOST='${BBHOSTNAME}'&SERVICE='${BBSVCNAME}'"}' --request POST "https://api.pushbullet.com/v2/pushes"
```
