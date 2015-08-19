FROM centos:latest
MAINTAINER Henrik Feldt <henrik@haf.se>

# mono & es build deps
COPY packagecloud-haf.sh /root/
RUN /root/packagecloud-haf.sh
RUN yum update -y && yum install -y epel-release yum-utils && \
    rpm --rebuilddb && \

    yum install -y \
    make tar patch gcc gcc-c++ git subversion \
      libgdiplus \
      glib2-devel \
      libpng-devel \
      libjpeg-turbo-devel \
      giflib-devel \
      libtiff-devel \
      libexif-devel \
      libX11-devel \
      fontconfig-devel \
      gettext \
      autoconf \
      automake \
      libtool \

      mono # from haf_oss

ENV PKG_CONFIG_PATH /usr/lib/pkgconfig
RUN pkg-config --cflags monosgen-2 # sanity check after installation
RUN echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH, PATH: $PATH, Mono Version: $(mono --version)"

# build es
ENV ITERATION 3
ENV ES_VERSION 3.1.0

RUN git clone https://github.com/EventStore/EventStore.git /tmp/esrepo
WORKDIR /tmp/esrepo
RUN git checkout ab530c0 # origin/unalign branch
RUN git submodule update --init
RUN sed -i 's/vNodeSettings[.]MaxMemtableEntryCount [*] 2/vNodeSettings.MaxMemtableEntryCount/g' src/EventStore.Core/ClusterVNode.cs
COPY package-mono-rhel.sh /tmp/esrepo/scripts/package-mono/package-mono-rhel.sh
COPY build.sh /tmp/esrepo/build.sh
COPY build-complement.sh /tmp/esrepo/build-complement.sh
COPY build-prepare.sh /tmp/esrepo/build-prepare.sh
RUN ./build-prepare.sh full $ES_VERSION x64 release
RUN ./build.sh full $ES_VERSION x64 release
RUN xbuild src/EventStore.sln /p:Platform="Any CPU" /p:Configuration=release
RUN ./scripts/package-mono/package-mono-rhel.sh $ES_VERSION

# package es
RUN rpm --rebuilddb && \
    yum install -y ruby-devel rubygems rubygems-devel rpm-build redhat-rpm-config && \
    gem install fpm --no-rdoc --no-ri
RUN mkdir -p /tmp/pkgbase/opt/eventstore
WORKDIR /tmp/pkgbase
RUN tar xf /tmp/esrepo/packages/EventStore-OSS-Mono-rhel-v$ES_VERSION.tar.gz && \
    mv EventStore-OSS-Mono-rhel-v$ES_VERSION/* ./opt/eventstore && \
    rmdir EventStore-OSS-rhel-v$ES_VERSION/ && \
    fpm -s dir -t rpm -n eventstore -v $ES_VERSION --iteration $ITERATION -a x86_64 -C /tmp/pkgbase .

VOLUME ["/tmp/home"]
WORKDIR /tmp/home
ENTRYPOINT ["/bin/bash"]
