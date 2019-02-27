# Monter un tunnel ssh socks

```{r, engine='bash', count_lines}
ssh -D 8123 -f -C -q -N <remote_host>
```

# Tester avec chromium-browser

```{r, engine='bash', count_lines}
sudo apt install -y chromium-browser
chromium-browser --proxy-server="socks5://localhost:8123"
```

# Tester en allant sur https://canihazip.com

# NodeJS & NPM installation

https://websiteforstudents.com/install-the-latest-node-js-and-nmp-packages-on-ubuntu-16-04-18-04-lts/

```{r, engine='bash', count_lines}
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt install -y nodejs
nodejs -v
npm -v
```

# Se rendre sur le repo du projet (Developpe avec NodeJS) : https://github.com/oyyd/http-proxy-to-socks

```{r, engine='bash', count_lines}
sudo npm install -g http-proxy-to-socks
hpts -s 127.0.0.1:8123 -p 8080
```

Aller sur : https://stackoverflow.com/questions/26550360/docker-ubuntu-behind-proxy

# Ubuntu 14.04

cat /etc/default/docker

```{r, engine='bash', count_lines}
export http_proxy="http://127.0.0.1:8080/"
# export https_proxy="https://127.0.0.1:8080/"
```

Puis :

```{r, engine='bash', count_lines}
service docker restart
```

# Ubuntu 18.04 / 16.04 LTS

cat /etc/systemd/system/docker.service.d/http-proxy.conf

```{r, engine='bash', count_lines}
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:8080/"
Environment="NO_PROXY=localhost,127.0.0.0/8,.domain1,.domain2,..."
```

Puis :

```{r, engine='bash', count_lines}
systemctl daemon-reload
systemctl restart docker.service
```

Puis faire un script en user:

cat launch_proxy_socks.sh

```{r, engine='bash', count_lines}
#!/bin/bash

ssh -D 8123 -f -C -q -N <remote_host>
hpts -s 127.0.0.1:8123 -p 8080 &
exit 0
```
