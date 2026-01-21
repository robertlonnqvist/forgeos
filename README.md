# My personal workstation built from Fedora Silverblue

Build and publish with:

```shell
$ podman build --no-cache -t registry.hyacinten.net/forgeos:latest .
$ podman push registry.hyacinten.net/forgeos:latest --tls-verify=false
```

To view changes from upstream:

```
$ skopeo inspect docker://quay.io/fedora/fedora-silverblue:43 | jq .Digest
$ podman image inspect quay.io/fedora/fedora-silverblue:43 --format '{{.Digest}}'
```

To update the local image

```
$ podman pull docker://quay.io/fedora/fedora-silverblue:43
```
