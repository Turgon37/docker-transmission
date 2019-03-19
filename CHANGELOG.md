# Changelog

Items starting with `DEPRECATE` are important deprecation notices.

## 3.0.0 (2019-03-19)

### Image

- Replace start.sh by entrypoint

## 2.1.0 (2018-02-04)

### Image

+ Add healthcheck

## 2.0.0 (2018-02-03)

### Image

+ Upgrade to Alpine 3.7
+ Remove s6-overlay, run transmission-daemon directly
+ Remove the internal crond service, so you must setup a docker external cron to call /opt/transmission/blocklist-update.sh

### Transmission

* Moved the default email notification script to /opt/transmission/mail-notification.sh. This modification will be transparent if you had set the /config as a docker volume. Otherwise you will need to update your settings.json.

## 1.0.0 (2017-08-07)

First release
