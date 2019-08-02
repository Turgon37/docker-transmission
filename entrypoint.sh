#!/bin/sh

set -e

## Configure timezone
function setTimezone() {
  if [ -n "${TZ}" ]; then
    echo "Configuring timezone to ${TZ}..."
    if [ ! -f "/usr/share/zoneinfo/${TZ}" ]; then
      echo "...#ERROR# failed to link timezone data from /usr/share/zoneinfo/${TZ}" 1>&2
      exit 1
    fi
    ln -snf /usr/share/zoneinfo/$TZ /config/localtime
    echo $TZ > /config/timezone
  fi
}

# run sartup action only if main command is given to entrypoint
if expr match $1 '.*transmission-daemon' >/dev/null; then
  setTimezone

  # copy config
  echo 'Copying default config...'
  if [ ! -f "/config/settings.json" ]; then
    cp /defaults/settings.json /config/settings.json
    chown transmission:transmission /config/settings.json
  fi

  echo 'Configure ssmtp for email notification...'
  ssmtp_conf=/etc/ssmtp/ssmtp.conf

  # configure ssmtp
  sed -i "s|^mailhub=mail|mailhub=${SMTP_SERVER}:${SMTP_PORT:-25}|" "${ssmtp_conf}"
  if ! grep 'FromLineOverride=yes' "${ssmtp_conf}"; then
    echo 'FromLineOverride=yes' >> "${ssmtp_conf}"
  fi
  # auth
  if [ -n "${SMTP_USERNAME}" -a -n "${SMTP_PASSWORD}" ]; then
    if ! grep 'AuthUser=' "${ssmtp_conf}"; then
      echo "AuthUser=${SMTP_USERNAME}" >> "${ssmtp_conf}"
    fi
    if ! grep 'AuthPass=' "${ssmtp_conf}"; then
      echo "AuthPass=${SMTP_PASSWORD}" >> "${ssmtp_conf}"
    fi
    if ! grep 'AuthMethod=' "${ssmtp_conf}"; then
      echo 'AuthMethod=LOGIN' >> "${ssmtp_conf}"
    fi
  fi
  # ssl
  if [ -n "${SMTP_STARTTLS}" -a "${SMTP_STARTTLS}" = "yes" ] && ! grep 'UseSTARTTLS=Yes' "${ssmtp_conf}"; then
    echo 'UseSTARTTLS=Yes' >> "${ssmtp_conf}"
  fi
  if [ -n "${SMTP_SSL}" -a "${SMTP_SSL}" = "yes" ] && ! grep 'UseTLS=Yes' "${ssmtp_conf}"; then
    echo 'UseTLS=Yes' >> "${ssmtp_conf}"
  fi

fi

## Start
exec "$@"
