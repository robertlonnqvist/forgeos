# My personal workstation built from Fedora Silverblue

Build and publish with:

```shell
$ podman build --no-cache -t registry.hyacinten.net/forgeos:latest .
$ podman push registry.hyacinten.net/forgeos:latest
```

To update to the latest fedora image

```
$ podman pull docker://quay.io/fedora/fedora-silverblue:43
```
