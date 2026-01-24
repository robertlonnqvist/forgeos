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
$ rpm-ostree db diff --changelos
```

Registry

```
$ mkdir -p ~/.config/containers/systemd/
$ cp -r registry/systemd/registry.container ~/.config/containers/systemd/
$ sudo cp registry/registries.conf /etc/containers/registries.conf.d/local-registry.conf
```

Cleanup

```
$ podman system prune
$ podman exec -it local-registry bin/registry garbage-collect /etc/docker/registry/config.yml
```
