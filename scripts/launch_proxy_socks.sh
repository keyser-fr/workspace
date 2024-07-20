#!/bin/bash

ssh -D 8123 -f -C -q -N sd-40290
hpts -s 127.0.0.1:8123 -p 8080 &
exit 0
