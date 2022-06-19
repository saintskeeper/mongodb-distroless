FROM docker.io/bitnami/minideb:buster AS mongodb
ARG DEBIAN_FRONTEND=noninteractive
ARG resolvingdeps=https://github.com/tran4774/Resolving-Shared-Library/releases/download/v1.0.3/resolving.sh
ARG mongo_version=5.0
ARG mongo_pgp=https://www.mongodb.org/static/pgp/server-${mongo_version}.asc
ADD ${resolvingdeps} /home/resolvingdeps.sh
ADD ${mongo_pgp} /home/key.asc
RUN \
  apt-get update && apt-get install gnupg -y \
  && apt-key add /home/key.asc \
  && echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/${mongo_version} main" | tee /etc/apt/sources.list.d/mongodb-org-${mongo_version}.list \
  && apt-get update \
  && apt-get install mongodb-org-server -y \
  && apt-get purge -y gnupg
RUN \
  chmod +x /home/resolvingdeps.sh \
  && /home/resolvingdeps.sh -f /usr/bin/mongod -d /home/deps \
  && apt-get autoremove -y \
  && apt-get autoclean --dry-run \
  && apt-get clean --dry-run


FROM gcr.io/distroless/static
COPY --from=mongodb /etc/mongod.conf /etc/
COPY --from=mongodb /usr/bin/mongod /usr/bin/
COPY --from=mongodb /etc/apt/sources.list.d /data/db
COPY --from=mongodb /home/deps/ /
EXPOSE 27017
ENTRYPOINT [ "mongod", "--bind_ip", "0.0.0.0" ]
