# Time-lapse Microservice

Use libgphoto2 to capture images using compatible cameras and expose certain
functionality over a REST API as a service.

## Building

### Fedora 24/25/26

```bash
sudo dnf install libgphoto2-devel libgee-devel
sudo dnf install libgda-devel libgda-sqlite libgda-mysql libgda-postgres
meson _build
ninja -C _build
sudo ninja -C _build install
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
```
