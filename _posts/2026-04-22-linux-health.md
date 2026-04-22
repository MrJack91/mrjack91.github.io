---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
categories: linux, journalctl
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

```bash
systemctl --failed

journalctl --boot=0 --priority=3 --no-pager
lnav
# :set-min-log-level error, :filter-out xx
journalctl --since '-12 hours' | lnav

# list all old config -> maybve we can remove it
apt list | grep "\[residual-config\]"

```