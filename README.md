# Supported tags and respective `Dockerfile` links

- [`latest` (*latest/Dockerfile*)](https://github.com/SillyWhale/unison/blob/master/Dockerfile)

# Quick reference

- **Where to file issues**:  
  [https://github.com/SillyWhale/unison/issues](https://github.com/SillyWhale/unison/issues)

- **Maintained by**:  
  [SillyWhale](https://github.com/SillyWhale/unison)

- **Source of this description**:  
  [docs repo's directory](https://github.com/SillyWhale/_documentation)

- **Supported Docker versions**:  
  [the latest release](https://github.com/docker/docker-ce/releases/latest)

# What is unison ?

[Unison](https://www.cis.upenn.edu/~bcpierce/unison/) description.

# How to use this image

## Usage

Use like you would any other base image:

```dockerfile
# Create base image to reuse for all steps
FROM alpine:3.8 AS base
LABEL maintainer="SillyWhale <contact@sillywhale.wtf>"

COPY includes/init.sh /init.sh
RUN \
  apk -U --no-cache upgrade && \
  apk add --no-cache openssh-server openssh-sftp-server openssh-server-pam linux-pam rsync && \
  mkdir /unison-datas && \
  mkdir /unison-confs && \
  mkdir /run/sshd && \
  chmod +x /init.sh
COPY includes/sshd_config /etc/ssh/sshd_config

# Builder image to compile unison from git repository
FROM base AS builder
LABEL maintainer="SillyWhale <contact@sillywhale.wtf>"

ENV US_VERSION=2.51.2 \
    US_ROOT=/opt/unison \
    US_URL=https://github.com/bcpierce00/unison/

RUN \
  apk -U --no-cache upgrade && \
  apk -U --no-cache add opam git ocaml ca-certificates make build-base bash

RUN \
    git clone ${US_URL} ${US_ROOT} && \
    cd ${US_ROOT} && \
    git checkout v${US_VERSION}

RUN \
  cd ${US_ROOT}/src && \
  wget https://git.alpinelinux.org/cgit/aports/plain/community/unison/fix-inotify-check.patch && \
  patch ${US_ROOT}/src/fsmonitor/linux/inotify_stubs.c fix-inotify-check.patch

RUN \
    cd ${US_ROOT} && \
    eval $(opam config env) && \
    make

## Build final image
FROM base
LABEL maintainer="SillyWhale <contact@sillywhale.wtf>"

ENV US_ROOT=/opt/unison

COPY --from=builder  ${US_ROOT}/src/unison /usr/bin/unison
COPY --from=builder  ${US_ROOT}/src/unison-fsmonitor /usr/bin/unison-fsmonitor

CMD [ "/init.sh" ]
```

This yields us a virtual image size of about ~15MB image.

## Documentation

This image is well documented. [Check out the documentation at Viewdocs](http://docs.sillywhale.wtf/unison/).

# License

View [license information](https://github.com/bcpierce00/unison/blob/master/LICENSE) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
