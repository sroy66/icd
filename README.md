# Image Capture Service

Use libgphoto2 to capture images using compatible cameras and expose certain
functionality over a REST API as a service.

The API is generated from RAML and can be viewed [here](doc/api/API.md).

## Setup

### Fedora

```bash
sudo dnf install python-pip3 cmake valac flex bison gettext \
    libgphoto2-devel libgee-devel json-glib-devel libgda-devel libgda-sqlite \
    libgda-mysql libgda-postgres libsoup2.4-devel libxml2-devel openssl-devel \
    libxml2-devel libgtop2-devel glib2-devel
```

### Debian/Ubuntu

```bash
sudo apt-get install python3-pip cmake valac flex bison gettext \
    libgda-5.0-dev libgee-0.8-dev libgirepository1.0-dev libglib2.0-dev \
    libgphoto2-dev libjson-glib-dev libsoup2.4-dev libssl-dev libxml2-utils \
    libgtop2-dev
```

### Common

A couple of the build dependencies are added to this repository as `meson`
subprojects and during testing it isn't necessary to install them.

```bash
sudo pip3 install scikit-build
sudo pip3 install meson ninja
git clone https://github.com/chergert/template-glib.git
cd template-glib
meson --prefix=/usr _build
ninja -C _build
sudo ninja -C _build install
cd ..
git clone https://github.com/valum-framework/valum.git
cd valum
meson --prefix=/usr --buildtype=release _build
ninja -C _build
sudo ninja -C _build install
```

### Cameras

USB cameras need to have the permissions changed, possibly just if the settings
will be changed. The example `udev` rule below is for a Canon camera that was
used during development.

```bash
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="04a9", ATTR{idProduct}=="3218", MODE="0666"' | \
    sudo tee /etc/udev/rules.d/50-canon.rules >/dev/null
sudo udevadm control --reload
sudo udevadm trigger
```

## Build/Install

```bash
git clone git@github.com:geoffjay/icd.git icd
cd icd
# During development
meson _build
ninja -C _build
# or
# For deployment
meson --prefix=/usr --sysconfdir=/etc --buildtype=plain _build
meson configure -Denable-systemd=true _build
ninja -C _build
sudo ninja -C _build install
```

### Post Install

Valum doesn't set the library path for the VSGI `.so` files that are needed so
this is necessary to execute `icd` once installed.

```bash
echo /usr/lib64/vsgi-0.3/servers | \
  sudo tee /etc/ld.so.conf.d/valum-x86_64.conf >/dev/null
sudo ldconfig
```

## Docker

Build and run the application using `Docker`.

```bash
docker build -t icd .
docker run --rm -it --privileged -v /dev/bus/usb:/dev/bus/usb -p 3003:3003 icd
```

Or with Docker Compose.

```bash
docker-compose up
```

This will put the database for the application in `/usr/share/icd`. This can be
changed by editing the configuration file in `data/config` to point at a
different volume that is mapped in a similar way as is done with the USB bus.

## Running

### Configuration

#### Properties

| Group    | Name        | Data Type    | Description                |
| -------- | ----------- | ------------ | -------------------------- |
| general  | address     | string       | Service IP address to use  |
| general  | port        | int          | Service port number to use |
| database | reset       | boolean      | Flag to reset the database |
| database | host        | string       | Database host IP address   |
| database | port        | int          | Database port number       |
| database | name        | string       | Database name              |
| database | provider    | string       | Database provider          |
| database | username    | string       | Database user name         |
| database | password    | string       | Database password          |
| database | dsn         | string       | Data service name          |

#### SQLite Sample

```bash
[general]
address = 127.0.0.1
port = 3003

[database]
reset = false
name = icd
provider = SQLite
path = /usr/share/icd/
