#!/bin/bash

sudo --background openvpn --config /home/dbonfils/opt/openvpn/dbonfils.ovpn

# or better via systemctl
# sudo systemctl status openvpn@dbonfils.service
# sudo systemctl start openvpn@dbonfils.service
# sudo systemctl stop openvpn@dbonfils.service
