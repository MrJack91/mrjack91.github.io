---
layout: post
title: "telnet, wie telnet, aber ohne telnet"
categories: linux, command, telnet, network
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

Telnet ohne admin und ohne telnet:
```bash
(timeout 1 bash -c '</dev/tcp/<ip>/<port> && echo PORT OPEN || echo PORT CLOSED') 2>/dev/null
```
