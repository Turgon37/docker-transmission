# Docker Bittorent Transmission

[![Build Status](https://travis-ci.org/Turgon37/docker-transmission.svg?branch=master)](https://travis-ci.org/Turgon37/docker-transmission)
[![](https://images.microbadger.com/badges/image/turgon37/transmission.svg)](https://microbadger.com/images/turgon37/transmission "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/turgon37/transmission.svg)](https://microbadger.com/images/turgon37/transmission "Get your own version badge on microbadger.com")

This image contains an instance of [Transmission client](https://www.transmissionbt.com/).
This project was inspired from [this project](https://github.com/linuxserver/docker-transmission) and rewrited to provide most of the configuration with ENV variables.

:warning: Take care of the [changelogs](CHANGELOG.md) because some breaking changes may happend between versions.

## Supported tags and respective Dockerfile links

* [`latest`](https://github.com/Turgon37/docker-transmission/blob/master/Dockerfile)

## Docker Informations

* This image exposes the following ports

| Port                | Usage        |
| ------------------- | ------------ |
| 9091                | HTTP Web UI  |
| 51413/tcp  51413/udp| Peering port |

 * This image takes theses environnements variables as parameters

| Environment       | Type         | Usage             |
| ------------------| ------------ | ------------------|
| TZ                | String       | Set the timezone  |


   * This volume is bind on this image

| Volume     | Usage                                            |
| ---------- | ------------------------------------------------ |
| /config    | Store configuration and torrents stats files     |
| /downloads | Path where the torrent's content will be put     |
| /watch     | Watch folder to allow automatic .torrent loading |


## Features

### Securing the webui with a username/password.

this requires 3 settings to be changed in the settings.json file.

Make sure the container is stopped before editing these settings.

`"rpc-authentication-required": true,` - check this, the default is false, change to true.

`"rpc-username": "transmission",` substitute transmission for your chosen user name, this is just an example.

`rpc-password` will be a hash starting with {, replace everything including the { with your chosen password, keeping the quotes.

Transmission will convert it to a hash when you restart the container after making the above edits.

### Updating Blocklists Automatically

You can configure an external cron job to update automatically the blocklists.
This requires `"blocklist-enabled": true,` to be set. By setting this to true, it is assumed you have also populated `blocklist-url` with a valid block list.

The automatic update is a shell script that downloads a blocklist from the url stored in the settings.json, gunzips it, and restarts the transmission daemon.

```
0 3 * * * root docker ps | grep --quiet 'transmission$' && docker exec --user transmission transmission /opt/transmission/blocklist-update.sh
```

### Notification by mails for done torrents

A notification script is included into this container. This script is run each times a Torrent has finished to be downloaded. By default it is able to send a mail but you can edit it to make something else.
You can activate in by simply configure at least the following environment variables into your container

| Name of the value  | Type              | Description                                                  |
| ------------------ | ----------------- | ------------------------------------------------------------ |
| SMTP_SERVER        | hostname/adress   | The address of the smtp server                               |
| MAIL_FROM          | string            | The email address of the sender of the email                 |
| MAIL_TO            | string            | The semi-colon separated list of recipient emails address(es) |

The following parameters are optionnal, they depends of your configuration needs

| Name of the value  | Type         | Description                                                           |
| ------------------ | ------------ | --------------------------------------------------------------------- |
| SMTP_PORT          | int          | The SMTP port of the server (default to 25)                           |
| SMTP_USERNAME      | string       | The optionnal login username to authenticate against the email server |
| SMTP_PASSWORD      | string       | The optionnal login password to authenticate against the email server |
| SMTP_SSL           | bool(yes/no) | Enable SSL connection to the email server                             |
| SMTP_STARTTLS      | bool(yes/no) | Enable STARTTLS mode for connection to the email server               |
| MAIL_SUBJECT       | string       | The subject's string of the email                                     |

You can include any other environment variable that will be available in the mail body of the notification script (localised into /config/mail-notification.py)


## Installation

```
docker pull turgon37/transmission
```

## Usage

```
docker run -p 80:9091 turgon37/transmission
```


### Docker-compose Specific configuration examples

* Simple docker-compose setting with smtp configuration

```
services:
  transmission:
    image: turgon37/transmission
    environment:
      - SMTP_SERVER=10.0.0.1
      - MAIL_FROM=noreply@domain.net
      - MAIL_TO=torrent@domain.net
    ports:
      - "127.0.0.1:8002:51413:51413/tcp"
      - "127.0.0.1:8002:51413:51413/udp"
      - "127.0.0.1:8001:9091/tcp"
    volumes:
      - data-transmission:/config
      - data-transmission-download:/downloads/complete"
      - data-transmission-incomplete:/downloads/incomplete"
      - data-transmission-watch:/watch"
volumes:
  data-transmission:
  data-transmission-download:
  data-transmission-incomplete:
  data-transmission-watch:
```
