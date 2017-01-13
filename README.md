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


| Environment                  | Usage                                                                                                                                      |
| ---------------------------- | -----------------------------------------------------------------------------------------------------------------------------------------  |
| RELAY_MYHOSTNAME             | The hostname of the SMTP relay (because docker assign a random hostname, you can specify here a human-readable hostname)                   |
| RELAY_MYDOMAIN   (mandatory) | The domain name that this relay will forward the mail                                                                                      |
| RELAY_MYNETWORKS             | The list of network(s) which are allowed by default to relay emails                                                                        |
| RELAY_HOST       (mandatory) | The remote host to which send the relayed emails (the relayhost)                                                                           |
| RELAY_LOGIN                  | The login name to present to the relayhost during authentication (optionnal)                                                               |
| RELAY_PASSWORD               | The password to present to the relayhost during authentication (optionnal)                                                                 |
| RELAY_USE_TLS                | Specify if you want to require a TLS connection to relayhost                                                                               |
| RELAY_TLS_VERIFY             | How to verify the TLS  : (none, may, encrypt, dane, dane-only, fingerprint, verify, secure)                                                |
| RELAY_TLS_CA                 | The path to the CA file use to check relayhost certificate (path in the container)                                                         |
| RELAY_POSTMASTER             | The email address of the postmaster, in order to send error, and misconfiguration notification                                             |
| RELAY_STRICT_SENDER_MYDOMAIN | If set to 'true' all sender adresses must belong to the relay domains                                                                      |
| RELAY_MODE                   | The predefined mode of relay behaviour, theses modes has been designed by me. The availables values for this parameter are described below |

#### Relay Mode

Description of parameter

| Relay mode value       | Description                                                                                                                                        | Usage                                                                                                                                                                                                                                                                                                   |
| ---------------------- |--------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| STRICT                 | Only network and sasl authenticated users can send emails through relay. All emails must have a recipient adress which belong to the relay domains |  Typically you can use this mode to allow one of your application to send email to internals domain emails adresses                                                                                                                                                                                     |
| ALLOW_SASLAUTH_NODOMAIN| Only network and sasl authenticated users can send emails through relay. All emails send by network authenticated users must have a recipient adress which belong to the relay domains. All emails send by sasl authenticated users can have any recipient adress(es).| You can use this mode to allow one of your (internal) application to send email to external users. In case when some part(s) of your application will be reachable by externals users|
| ALLOW_NETAUTH_NODOMAIN | Only network and sasl authenticated users can send emails through relay. All emails send by sasl authenticated users must have a recipient adress which belong to the relay domains. All emails send by network authenticated users can have any recipient adress(es) | |
| ALLOW_AUTH_NODOMAIN    | Only network and sasl authenticated users can send emails through relay. All emails send by all authenticated users can have any recipient adress(es). | In case where you want a simple relay host with a basic auth |

For other examples of values, you can refer to the Dockerfile

## Installation

* Manual

```
git clone
docker build -t turgon37/smtp-relay .
```

* or Automatic

```
docker pull turgon37/smtp-relay
```

## Usage

```
docker run -p 25:25 -e "RELAY_MYDOMAIN=domain.com" -e "RELAY_HOST=relay:25" docker-smtp-relay
```

### Configuration during running

   * Add a SASL user :

If you have a host which is not in the range of addresses specified in 'mynetworks' of postfix, this host have to be sasl authenticated when it connects to the smtp relay.

To create a generic account for this host you have to run this command into the container

```
/saslpasswd.sh -u domain.com -c username
```

You have to replace domain.com with your relay domain and you will be prompt for password two times.


   * Add multiple SASL users : 

If you want to add multiple sasl users at the same time you can mount (-v) your credentials list to /etc/postfix/client_sasl_passwd
This list must contains one credential per line and for each line use the syntax  'USERNAME PASSWORD'  (the username and the password are separated with a blank space)

You can check with docker logs if all of your line has been correctly parsed
