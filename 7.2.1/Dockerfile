FROM armv7/armhf-ubuntu:14.04.3

ARG NODE_VERSION=7.2.1
ARG YARN_VERSION=0.24.6

RUN apt-get update && \
    apt-get -y --force-yes install xz-utils curl jq lsof

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
  done

RUN curl -SLO "https://nodejs.org/dist/v7.2.1/node-v7.2.1-linux-armv7l.tar.xz"
RUN curl -SLO --compressed "https://nodejs.org/dist/v7.2.1/SHASUMS256.txt.asc"
RUN gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc
RUN grep " node-v7.2.1-linux-armv7l.tar.xz\$" SHASUMS256.txt | sha256sum -c -
RUN ls -lah "node-v7.2.1-linux-armv7l.tar.xz"
RUN tar -xJf "node-v7.2.1-linux-armv7l.tar.xz" -C /usr/local --strip-components=1
RUN rm "node-v7.2.1-linux-armv7l.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
  done \
  && curl -fSLO --compressed "https://yarnpkg.com/downloads/0.24.6/yarn-v0.24.6.tar.gz" \
  && curl -fSLO --compressed "https://yarnpkg.com/downloads/0.24.6/yarn-v0.24.6.tar.gz.asc" \
  && gpg --batch --verify yarn-v0.24.6.tar.gz.asc yarn-v0.24.6.tar.gz \
  && mkdir -p /opt/yarn \
  && tar -xzf yarn-v0.24.6.tar.gz -C /opt/yarn --strip-components=1 \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && rm yarn-v0.24.6.tar.gz.asc yarn-v0.24.6.tar.gz

CMD [ "node" ]
