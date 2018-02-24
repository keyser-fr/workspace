# Deployer lvm sur une debian fraichement installee (par exemple pour une dedibox) - Oct 25, 2017

[Source](http://tutos.tangui.eu.org/2017/10/25/deployer-lvm-debian/)

* Installation de lvm et rsync :

En root :

```bash
aptitude install lvm2 rsync
```

* Recuperer la localisation nom de la partition data :

```bash
df -h
```

Ici on a :

```bash
/dev/sda2                     900G  0   900G   0% /data
```

* Demontage et suppression de la partition /data :

```bash
umount /data
rm -rf /data
```

* Creation du volume physique sur la partition qui contenait /data :

```bash
pvcreate /dev/sda4
```

* Creation du groupe lvm

```bash
vgcreate volgroup /dev/sda4
```

* Pour verifier que tout a ete bien cree

```bash
vgdisplay
```

* Creation des partitions lvm logique

```bash
lvcreate -L 50G -n varlib /dev/volgroup
lvcreate -L 20G -n home /dev/volgroup
```

* Formatage des partitions en ext4

```bash
mkfs.ext4 /dev/volgroup/varlib
mkfs.ext4 /dev/volgroup/home
```

* Montage des partitions du lvm dans home pour les synchroniser avec les dossiers actuels

```bash
mkdir /tmp/home
mkdir /tmp/varlib

mount /dev/volgroup/home /tmp/home/
mount /dev/volgroup/varlib /tmp/varlib/
```

* Synchronisation du contenu des dossiers dans les partitions lvm

```bash
rsync -a /home/ /tmp/home/
rsync -a /var/lib/ /tmp/varlib/
```

* Ajouter les partitions lvm dans le fichier **/etc/fstab** pour le montage automatique

```bash
/dev/volgroup/varlib                      /var/lib        ext4    defaults        0       2
/dev/volgroup/home                        /home           ext4    defaults        0       2
```

Ou mieux par UUID recuperable ici :

```bash
ls -l /dev/disk/by-uuid/
```

```bash
# /var/lib on /dev/sda4 (LVM - /dev/dm-0)
UUID=</dev/disk/by-uuid>                  /var/lib        ext4    defaults        0       2
# /home on /dev/sda4 (LVM - /dev/dm-1)
UUID=</dev/disk/by-uuid>                  /home           ext4    defaults        0       2
```

Ne pas oublier d'enlever le montage automatique du **/etc/fstab** de la partition sur /data

* Monter les partitions a partir du fstab

```bash
mount -a
```

* Pour verifier que tout est ok

```bash
mount
df -h
ls -l /home
ls -l /var/lib
```

* Demontages des montages dans /tmp

```bash
umount /tmp/home
umount /tmp/varlib
```

* Redemarrer la machine pour l'ultime controle

```bash
reboot
```

* Monter la partition root qui accueillait a l'origine la home et varlib

```bash
mkdir /tmp/root
mount /dev/sda2 /tmp/root/
```

* Supprimer le contenu des dosssiers home et varlib de la partition root

```bash
rm -rf /tmp/root/home/*
rm -rf /tmp/root/var/lib/*
```

* Demontage du root temporaire

```bash
umount /tmp/root
```
