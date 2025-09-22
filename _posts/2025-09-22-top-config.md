---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
categories: linux, top
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---

Meine basic `top` config.


## Die Config
Um nicht immer mit `h` die Help durchzulesen:


```txt
top
z: enable colors
E: set RAM to GB in header
e: set RAM to MB in list
V: tree view
t: cpu graphic
m: ram graphic
1/4: display cores, but split into 2 rows
c: display full command
B: make bold
x: display sort field
y: disable current process
move sort to mem

:W to write these configs
```

## Alias to the win
Meist habe ich einen `topu` alias, die mir nur die Prozesse des aktuellen Users anzeigt:
```bash
alias topu='top -u $(whoami)'

# or as a fish function
function topu --wraps='top -u $(whoami)' --description 'alias topu=top -u $(whoami)'
  top -u $(whoami) $argv
end

```

