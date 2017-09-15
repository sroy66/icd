# Image Capture Service

Use libgphoto2 to capture images using compatible cameras and expose certain
functionality over a REST API as a service.

## Setup

### Fedora 24/25/26

```bash
sudo dnf install libgphoto2-devel libgee-devel json-glib-devel
sudo dnf install libgda-devel libgda-sqlite libgda-mysql libgda-postgres
```

### RaspberryPi

```bash
sudo apt-get install python3-pip cmake valac git
sudo pip3 install scikit-build
sudo pip3 install meson ninja
sudo apt-get install flex bison libxml2-utils libsoup2.4-dev libgirepository1.0-dev libgphoto2-dev
# probably need to fix USB device permissions
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="04a9", ATTR{idProduct}=="3218", MODE="0666"' | \
sudo tee /etc/udev/rules.d/50-canon.rules >/dev/null
sudo udevadm control --reload
sudo udevadm trigger
mkdir src # or whatever
cd src
# would have liked to have template-glib as subproject but that requires more effort
git clone https://github.com/chergert/template-glib.git
cd template-glib
meson _build
meson configure -Dprefix=/usr _build
ninja -C _build
sudo ninja -C _build install
```

## Build/Install

```bash
git clone git@git.coanda.local:software/timelapse-microservice.git timelapse
cd timelapse
meson --prefix=/usr --sysconfdir=/etc _build
ninja -C _build
sudo ninja -C _build install
```

### Post Install

Valum doesn't correctly set the library path for the VSGI `.so` files that are
needed so this is necessary if installing using it using a repository.

```bash
echo /usr/lib64/vsgi-0.3/servers | \
  sudo tee /etc/ld.so.conf.d/valum-x86_64.conf >/dev/null
sudo ldconfig
```

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
address = 10.0.2.2
port = 3003

[database]
reset = false
name = cis
provider = SQLite
path = /srv/images/
