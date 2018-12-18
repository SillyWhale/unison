# Create base image to reuse for all steps
FROM alpine:3.8 AS base
LABEL maintainer="Vincent FRICOU <vincent+docker@fricouv.eu>"

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
LABEL maintainer="Vincent FRICOU <vincent+docker@fricouv.eu>"

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
LABEL maintainer="Vincent FRICOU <vincent+docker@fricouv.eu>"

ENV US_ROOT=/opt/unison

COPY --from=builder  ${US_ROOT}/src/unison /usr/bin/unison
COPY --from=builder  ${US_ROOT}/src/unison-fsmonitor /usr/bin/unison-fsmonitor

CMD [ "/init.sh" ]
