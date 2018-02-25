# Xymon

Xymon works

[Source](http://xymon.sourceforge.net/xymon/help/xymon-tips.html)

* So how do I get rid of an entire host in Xymon?

First, remove the host from the ~/server/etc/hosts.cfg file. Then use the command

```bash
~/server/bin/xymon 127.0.0.1 "drop HOSTNAME"
```

to permanenly remove all traces of a host. Note that you need the quotes around the "drop HOSTNAME".

* How do I rename a host in the Xymon display?

First, change the ~/server/etc/hosts.cfg file so it has the new name. Then to move your historical data over to the new name, run

```bash
~/server/bin/xymon 127.0.0.1 "rename OLDHOSTNAME NEWHOSTNAME"
```
