[hub]: https://hub.docker.com/r/spritsail/ombi
[git]: https://github.com/spritsail/ombi
[drone]: https://drone.spritsail.io/spritsail/ombi
[mbdg]: https://microbadger.com/images/spritsail/ombi

# [spritsail/Jackett][hub]

[![](https://images.microbadger.com/badges/image/spritsail/ombi.svg)][mbdg]
[![Latest Version](https://images.microbadger.com/badges/version/spritsail/ombi.svg)][hub]
[![Git Commit](https://images.microbadger.com/badges/commit/spritsail/ombi.svg)][git]
[![Docker Pulls](https://img.shields.io/docker/pulls/spritsail/ombi.svg)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/spritsail/ombi.svg)][hub]
[![Build Status](https://drone.spritsail.io/api/badges/spritsail/ombi/status.svg)][drone]


[Ombi](https://ombi.io) running in Alpine Linux, compiled from source for the smallest possible iamge

### Usage

```bash
docker run -dt
    --name=ombi
    --restart=always
    -v $PWD/config:/config
    -p 5000:5000
    spritsail/ombi
```

### Volumes

* `/config` - Ombi configuration file and database storage. Should be readable and writeable by `$SUID` 

`$SUID` defaults to 952

