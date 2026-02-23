# My personal workstation built from Fedora Silverblue

Build and publish with:

```shell
$ ./bin/build
```

To update to the latest fedora image

```shell
$ ./bin/update
```

To see changes between image version:
```shell
$ rpm-ostree db diff --changelogs
```

Registry

```shell
$ mkdir /var/home/robert/.registry-data
$ mkdir -p ~/.config/containers/systemd/
$ cp -r registry/systemd/registry.container ~/.config/containers/systemd/
$ sudo cp registry/registries.conf /etc/containers/registries.conf.d/local-registry.conf
$ systemctl --user daemon-reload
```

Use the new image
```shell
$ sudo bootc switch localhost:5000/forgeos:latest
```

Cleanup

```shell
$ podman system prune
$ podman exec -it local-registry bin/registry garbage-collect /etc/docker/registry/config.yml
```
