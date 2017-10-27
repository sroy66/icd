FROM debian:latest

MAINTAINER Geoff Johnson <geoff.jay@gmail.com>

RUN apt-get update
RUN apt-get install -y \
    libgda-5.0-dev \
    libgee-0.8-dev \
    libgirepository1.0-dev \
    libglib2.0-dev \
    libgphoto2-dev \
    libjson-glib-dev \
    libsoup2.4-dev \
    libssl-dev \
    libxml2-utils \
    bison \
    flex \
    gettext \
    git \
    python3-pip \
    unzip \
    valac
RUN rm -rf /var/lib/apt/lists/*

# Meson
RUN pip3 install meson

# Ninja
ADD https://github.com/ninja-build/ninja/releases/download/v1.6.0/ninja-linux.zip /tmp
RUN unzip /tmp/ninja-linux.zip -d /usr/local/bin

# Template-GLib
ADD https://github.com/chergert/template-glib/archive/3.25.92.tar.gz /tmp
RUN tar zxf /tmp/3.25.92.tar.gz -C /tmp
WORKDIR /tmp/template-glib-3.25.92
RUN meson --prefix=/usr _build
RUN ninja -C _build && ninja -C _build install

# Valum
ADD https://github.com/valum-framework/valum/archive/v0.3.13.tar.gz /tmp
RUN tar zxf /tmp/v0.3.13.tar.gz -C /tmp
WORKDIR /tmp/valum-0.3.13
RUN meson --prefix=/usr --buildtype=release _build
RUN ninja -C _build && ninja -C _build install
RUN echo /usr/lib/x86_64-linux-gnu/vsgi-0.3/servers | tee /etc/ld.so.conf.d/valum-x86_64.conf >/dev/null
RUN ldconfig

WORKDIR /icd
ADD . .
RUN meson --prefix=/usr --sysconfdir=/etc --buildtype=release _build
RUN meson configure -Denable-tests=false _build
RUN ninja -C _build && ninja -C _build install

CMD ["/usr/bin/icd", "--config", "/etc/icd/icd.conf"]

EXPOSE 3003
