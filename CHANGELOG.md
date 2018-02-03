# Changelog

Items starting with `DEPRECATE` are important deprecation notices.

## 2.0.0 (2018-02-03)

### Image

+ Remove s6-overlay, run transmission-daemon directly
+ Remove the internal crond service, so you must setup a docker external cron to call /opt/transmission/blocklist-update.sh

### Transmission

* Moved the default email notification script to /opt/transmission/mail-notification.sh. This modification will be transparent if you had set the /config as a docker volume. Otherwise you will need to update your settings.json.

### Deprecation

- Deprecate `GLPI_PLUGINS` environment variable in favor of GLPI_INSTALL_PLUGINS. GLPI_INSTALL_PLUGINS is comma separated and follow the same pattern as GLPI_PLUGINS.

## 1.0.0 (2017-08-07)

First release