FROM debian:buster
MAINTAINER jake@apache.org

ARG CLOJURE_VERSION=1.10.1.727
ARG LEININGEN_VERSION=2.9.4
ARG NODE_VERSION=14.17.3

ENV LEIN_ROOT true

#
# Jepsen dependencies
#
RUN apt-get -y -q update && \
    apt-get install -qy openjdk-11-jdk-headless \
    libjna-java \
    vim \
    emacs \
    git \
    htop \
    screen \
    pssh \
    curl \
    wget \
    gnuplot \
    graphviz \
    dos2unix \
    rlwrap  \
    gnupg \
    xz-utils

RUN wget https://download.clojure.org/install/linux-install-${CLOJURE_VERSION}.sh && \
    chmod +x linux-install-${CLOJURE_VERSION}.sh && \
    ./linux-install-${CLOJURE_VERSION}.sh && \
    rm linux-install-${CLOJURE_VERSION}.sh

RUN wget https://raw.githubusercontent.com/technomancy/leiningen/${LEININGEN_VERSION}/bin/lein && \
    mv lein /usr/bin && \
    chmod +x /usr/bin/lein && \
    lein self-install

RUN wget "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" && \
    wget "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" && \
    grep " node-v${NODE_VERSION}-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - && \
    tar -xJf "node-v${NODE_VERSION}-linux-x64.tar.xz" -C /usr/local --strip-components=1 --no-same-owner && \
    rm "node-v${NODE_VERSION}-linux-x64.tar.xz" SHASUMS256.txt && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs

RUN apt-key adv --keyserver "https://download.docker.com/linux/debian/gpg" \
        --recv "9DC858229FC7DD38854AE2D88D81803C0EBFCD88" && \
    mkdir -p "/etc/apt/sources.list.d/" && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" \
        > "/etc/apt/sources.list.d/docker.list" && \
    apt-get -y -q update && \
    apt-get install -qy libsodium23 docker-ce-cli

# without --dev flag up.sh copies jepsen to these subfolders
# with --dev flag they are empty until mounted
COPY jepsen/jepsen /jepsen/jepsen/
RUN if [ -f /jepsen/jepsen/project.clj ]; then cd /jepsen/jepsen && lein install; fi
COPY jepsen /jepsen/

ADD ./bashrc /root/.bashrc
ADD ./init.sh /init.sh
RUN dos2unix /init.sh /root/.bashrc \
    && chmod +x /init.sh

CMD /init.sh
