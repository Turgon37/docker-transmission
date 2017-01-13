#!/bin/sh

# Version 1.0

# Check requirements before run
if [ -z "${SMTP_SERVER}" -o -z "${MAIL_TO}" -o -z "${MAIL_FROM}" ]; then
  exit 0
fi

# set default subject
if [ -z "${MAIL_SUBJECT}" ]; then
  MAIL_SUBJECT='[Transmission] Torrent Done!'
fi

# Mail template
(
  echo "To: ${MAIL_TO}
From: ${MAIL_FROM}
Subject: ${MAIL_SUBJECT}
Hi,

This is an automated message reporting that the following torrent has finished to be downloaded.

Torrent informations:
  Torrent : ${TR_TORRENT_NAME}
  Time    : ${TR_TIME_LOCALTIME}
  Location: ${TR_TORRENT_DIR}
  Hash    : ${TR_TORRENT_HASH}
  ID      : ${TR_TORRENT_ID}
  Version : ${TR_APP_VERSION}

Regards"
) | sendmail ${MAIL_TO}
