#!/bin/sh

/etc/init.d/fail2ban stop

# Vider les tables actuelles
iptables -t filter -F

# Vider les regles personnelles
iptables -t filter -X

# Interdire toute connexion entrante et sortante
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT DROP

# ---

# Ne pas casser les connexions etablies
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Autoriser loopback
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT

# ICMP (Ping)
iptables -t filter -A INPUT -p icmp -j ACCEPT
iptables -t filter -A OUTPUT -p icmp -j ACCEPT

# ---

# SSH In/Out
iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 22 -j ACCEPT

# DNS In/Out
iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT

# NTP Out
iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT

# HTTP + HTTPS Out
iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT

# HTTP + HTTPS In
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT

# FTP Out 
iptables -t filter -A OUTPUT -p tcp --dport 20:21 -j ACCEPT 
 
# FTP In
modprobe ip_conntrack_ftp # ligne facultative avec les serveurs OVH
iptables -t filter -A INPUT -p tcp --dport 20:21 -j ACCEPT
iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# DMA Monitoring Dedibox
iptables -A INPUT -i eth0 -s 88.191.254.0/24 -p tcp --dport 161 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -s 88.191.254.0/24 -p udp --dport 161 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -d 88.191.254.0/24 -p tcp --sport 161 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -d 88.191.254.0/24 -p udp --sport 161 -m state --state ESTABLISHED -j ACCEPT

# Teamspeak In/Out
# UDP Teamspeak Voice Port
iptables -A INPUT -p udp -m udp --dport 9987 -j ACCEPT
# TCP Teamspeak File Transfer
iptables -A INPUT -p tcp -m tcp --dport 30033 -j ACCEPT
# TCP Query Port
iptables -A INPUT -p tcp -m tcp --dport 10011 -j ACCEPT
# Licence Port (2008) + web server list (2010)
iptables -A OUTPUT -p tcp -m tcp --dport 2008 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 2010 -j ACCEPT

# Visualisation des regles
iptables -L -v --line-numbers

/etc/init.d/fail2ban start

exit 0

