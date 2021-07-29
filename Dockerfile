FROM ubuntu:bionic as builder

ARG REPO=https://github.com/pvpgn/pvpgn-server.git
ARG BRANCH=master
ARG WITH_MYSQL=true
ARG WITH_LUA=true

### Install build dependencies
RUN apt-get update
RUN apt-get -y install build-essential git cmake zlib1g-dev
RUN apt-get -y install liblua5.1-0-dev
RUN apt-get -y install mysql-server mysql-client libmysqlclient-dev

### CMake & make
RUN git clone --single-branch --branch ${BRANCH} ${REPO} /src
RUN cd /src && cmake -D WITH_MYSQL=true -D WITH_LUA=true -G "Unix Makefiles" -H./ -B./build

### Install
WORKDIR /src/build
RUN make
RUN make install

### Set working directory
WORKDIR /usr/local/etc/pvpgn

### Prepare user
RUN addgroup --gid 1001 pvpgn \
  && adduser \
  --home /usr/local/etc/pvpgn \
  --gecos "" \
  --shell /bin/false \
  --ingroup pvpgn \
  --system \
  --disabled-password \
  --no-create-home \
  --uid 1001 \
  pvpgn

### Make volume folders
RUN mkdir -p /usr/local/var/pvpgn

### adjust permissions
RUN chown -R pvpgn:pvpgn /usr/local/var/pvpgn
RUN chown -R pvpgn:pvpgn /usr/local/etc/pvpgn

### persist data and configs
VOLUME /usr/local/var/pvpgn
VOLUME /usr/local/etc/pvpgn

# expose served network ports
EXPOSE 6112 4000

### Set user
USER pvpgn

### RUN!
CMD ["bnetd", "-f"]