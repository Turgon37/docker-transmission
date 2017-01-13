# Docker SMTP Relay

This image contains an instance of [Transmission client](https://www.transmissionbt.com/).
This project was inspired from [this project](https://github.com/linuxserver/docker-transmission) and rewrited to provide most of the configuration with ENV variables.


# Features

## Securing the webui with a username/password.

this requires 3 settings to be changed in the settings.json file.

`Make sure the container is stopped before editing these settings.`

`"rpc-authentication-required": true,` - check this, the default is false, change to true.

`"rpc-username": "transmission",` substitute transmission for your chosen user name, this is just an example.

`rpc-password` will be a hash starting with {, replace everything including the { with your chosen password, keeping the quotes.

Transmission will convert it to a hash when you restart the container after making the above edits.

## Updating Blocklists Automatically

This requires `"blocklist-enabled": true,` to be set. By setting this to true, it is assumed you have also populated `blocklist-url` with a valid block list.

The automatic update is a shell script that downloads a blocklist from the url stored in the settings.json, gunzips it, and restarts the transmission daemon.

The automatic update will run once a day at 3am local server time.

## Notification by mail for done torrents

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



## Docker Informations

   * This port is available on this image

| Port                 | Usage        |
| -------------------- | ------------ |
| 9091                 | HTTP Web UI  |
| 51413/tcp  51413/udp | Peering port |

   * This volume is bind on this image

| Volume     | Usage                                            |
| ---------- | ------------------------------------------------ |
| /config    | Store configuration and torrents stats files     |
| /downloads | Path where the torrent's content will be put     |
| /watch     | Watch folder to allow automatic .torrent loading |


  * This image takes theses environnements variables as parameters


| Environment                  | Usage        |
| ---------------------------- | -----------  |


## Installation

* Manual

```
git clone
docker build -t turgon37/transmission .
```

* or Automatic

```
docker pull turgon37/transmission
```

## Usage

```
docker run -p 80:9091 turgon37/transmission
```