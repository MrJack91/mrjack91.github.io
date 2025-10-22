---
layout: post
# title: "Some articles are just so short that we have to make the footer stick"
# categories: sap hana, cert, security
# meta: "Springfield"
# modified_date: 2016-05-27
published: true
# excerpt_separator: <!--end_excerpt-->
---


Per default docker logs are stored under `/var/lib/docker/containers/<container-id>/<container-id>-json.log`.
If the container gets deleted also the log is deleted.

As an alternative we can redirect docker logs to `journald`.

## set per container
This can be done on a container basis:
```bash
docker run --log-driver=journald --log-opt tag="xx" <image>
```

## set globally
Or also set globally:

```bash
sudo vi /etc/docker/daemon.json
  {
    "log-driver": "journald",
    "log-opts": {
      "tag": "{{.Name}}"
    }
  }

# this will restart all containers
sudo systemctl restart docker
```

# journalctl - list logs
To filter logs only from one container use:
```bash
# to see logs
journalctl SYSLOG_IDENTIFIER=<docker-container-name>
```

