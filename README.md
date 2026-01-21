# My personal workstation built from Fedora Silverblue

Build and publish with:

```shell
$ podman build --no-cache -t 10.0.0.2:5000/forgeos:latest .
$ podman push 10.0.0.2:5000/forgeos:latest --tls-verify=false
```

To view changes from upstream:

```
$ skopeo inspect docker://quay.io/fedora/fedora-silverblue:43 | jq .Digest
$ podman image inspect quay.io/fedora/fedora-silverblue:43 --format '{{.Digest}}'
```
