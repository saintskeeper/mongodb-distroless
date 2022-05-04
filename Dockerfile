FROM docker.io/bitnami/minideb:buster AS mongodb
ARG DEBIAN_FRONTEND=noninteractive
ADD https://www.mongodb.org/static/pgp/server-5.0.asc /home
RUN \
  apt-get update && apt-get install gnupg -y \
  && apt-key add /home/*.asc \
  && echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/5.0 main" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list \
  && apt-get update \
  && apt-get install mongodb-org-server -y \
  && apt-get purge -y gnupg \
  && apt-get autoremove -y \
  && apt-get autoclean --dry-run \
  && apt-get clean --dry-run \
  && rm /home/* \
  && mkdir /data && cd /data && mkdir db

FROM gcr.io/distroless/static:latest
COPY --from=mongodb /etc/mongod.conf /etc/
COPY --from=mongodb /usr/bin/mongod /usr/bin/
COPY --from=mongodb /lib64/ld-linux-x86-64.so.2 /lib64/
COPY --from=mongodb /etc/apt/sources.list.d /data/db/
COPY --from=mongodb /usr/lib/x86_64-linux-gnu/libcurl.so.4 \
  /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1\
  /usr/lib/x86_64-linux-gnu/libssl.so.1.1\
  /usr/lib/x86_64-linux-gnu/libnghttp2.so.14 \
  /usr/lib/x86_64-linux-gnu/libidn2.so.0 \
  /usr/lib/x86_64-linux-gnu/librtmp.so.1 \
  /usr/lib/x86_64-linux-gnu/libssh2.so.1 \
  /usr/lib/x86_64-linux-gnu/libpsl.so.5 \
  /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2 \
  /usr/lib/x86_64-linux-gnu/libkrb5.so.3 \
  /usr/lib/x86_64-linux-gnu/libk5crypto.so.3 \
  /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 \
  /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 \
  /usr/lib/x86_64-linux-gnu/libunistring.so.2 \
  /usr/lib/x86_64-linux-gnu/libgnutls.so.30 \
  /usr/lib/x86_64-linux-gnu/libhogweed.so.4 \
  /usr/lib/x86_64-linux-gnu/libnettle.so.6 \
  /usr/lib/x86_64-linux-gnu/libgmp.so.10 \
  /usr/lib/x86_64-linux-gnu/libkrb5support.so.0 \
  /usr/lib/x86_64-linux-gnu/libsasl2.so.2 \
  /usr/lib/x86_64-linux-gnu/libp11-kit.so.0 \
  /usr/lib/x86_64-linux-gnu/libtasn1.so.6 \
  /usr/lib/x86_64-linux-gnu/libffi.so.6 \
  /usr/lib/x86_64-linux-gnu/
COPY --from=mongodb /lib/x86_64-linux-gnu/liblzma.so.5 \
  /lib/x86_64-linux-gnu/libresolv.so.2 \
  /lib/x86_64-linux-gnu/libdl.so.2 \
  /lib/x86_64-linux-gnu/librt.so.1 \
  /lib/x86_64-linux-gnu/libm.so.6 \
  /lib/x86_64-linux-gnu/libgcc_s.so.1 \
  /lib/x86_64-linux-gnu/libpthread.so.0 \
  /lib/x86_64-linux-gnu/libc.so.6 \
  /lib/x86_64-linux-gnu/libz.so.1 \
  /lib/x86_64-linux-gnu/libcom_err.so.2 \
  /lib/x86_64-linux-gnu/libgcrypt.so.20 \
  /lib/x86_64-linux-gnu/libkeyutils.so.1 \
  /lib/x86_64-linux-gnu/libgpg-error.so.0 \
  /lib/x86_64-linux-gnu/
EXPOSE 27017
ENTRYPOINT [ "mongod", "--bind_ip", "0.0.0.0" ]
