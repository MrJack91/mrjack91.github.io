---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
# categories: sap hana, cert, security
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

Transfer files and dirs im Terminal

# Easy transfer in termial

```bash
# source - terminal 1
tar -czf - mydir | base64 -w0
tar -czf - mydir | base64 -w0 > mydir.txt

# destination - terminal 2
echo "PASTE-HERE" | base64 -d | tar -xzf -
base64 -d mydir.txt | tar -xzf -
```

