---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
# categories: sap hana, cert, security
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

Mit `rsync` versch. Config Files für Dokumentations- oder Backupzwecke zusammen suchen.

* `rsync` unterstütz filters, mit denen Files/Dirs in-/exkludiert werden können.
* Wichtig ist:
  * offizielle Syntax ist `+` für inkl., `-` für exkl.
    * wobei bei Verwendung von `--include-from=` `+` optional/default ist.
  * am Ende muss alles andere exkluded werden (`- *`)
  * jedes Parent Directory muss einzeln inkl. werden (ohne `*?`) --> sehr mühsam


```bash
> cat include.txt
/etc/

/etc/apt/
/etc/apt/apt.conf.d/
/etc/apt/apt.conf.d/51unattended-upgrades-usb

/etc/restic/
/etc/restic/**

/home
/home/*/
/home/*/.bashrc
/home/*/.config/
/home/*/.config/fish/
/home/*/.config/fish/functions/
/home/*/.config/fish/functions/**

# we have to exclude everything else at the end
- *

```


```bash
# archive mode, relative Ordner Struktur belassen, include list verwenden
#
# archive: -rlptgoD
#   - r: recursive
#   - l: links (keep symlinks)
#   - p: perms (keep)
#   - t: times ()
#   - g: groups
#   - o: owners
#   - D: devices and special files (preserve device files)

rsync -avh --prune-empty-dirs --delete --relative --include-from=include.txt / /srv/backup-config
```

