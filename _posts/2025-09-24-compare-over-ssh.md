---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
categories: linux, ssh, sshfs, wsl, diff, winmerge
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---


Nutze SSHFS mounts um Configs zu vergleichen.

## Easy mount in Linux or WSL

```bash
apt install sshfs

sshfs pk:/etc/monit/conf.d pk
sshfs pp:/etc/monit/conf.d pp

# list files incl. permission, user and group
tree -pug

icdiff pk pp

umount pk pp
```

## Mount for accessing from Windows through WSL
`sshfs` erzeugt die Mounts nur für den aktuellen User, d.h. der Windows User kann nicht drauf zugreifen.

```bash
# enable user_allow_other
vi /etc/fuse.conf
    user_allow_other

sshfs -o allow_other pk:/etc/monit/ pk
sshfs -o allow_other pp:/etc/monit/ pp
# other options:
#   default_permissions: using normal kernel and not fuse permission
#   uid/gid: map remote users to current (wsl) user
# e.g. default_permissions,uid=$(id -u),gid=$(id -g)

# list files incl. permission, user and group
tree -pug

# make sure permissions are correct
# chmod o+rw *

# now use winmerge over \\wsl.localhost\...


umount pk pp

# revert permission if adapted before
# chmod o-rw *
```

