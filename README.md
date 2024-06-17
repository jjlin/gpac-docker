Multi-arch builds of [GPAC](https://github.com/gpac/gpac), over an Ubuntu 24.04 (noble) base image.

## Example

Bind-mount your input directory to `/gpac`, which is also the default working directory:
```
$ ls
in.mp4
$ docker run --rm -v "$PWD:/gpac" jjlin/gpac MP4Box -inter 500 "in.mp4" -out "out.mp4"
[core] Creating default credential key in /root/.gpac/creds.key, use -cred=PATH/TO_FILE to overwrite
0.500 secs Interleaving
ISO File Writing: |================== | (99/100)
$ ls
in.mp4  out.mp4
```
