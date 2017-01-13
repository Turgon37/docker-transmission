#!/usr/bin/with-contenv sh

BLOCKLIST_ENABLED=$(jq -r '.["blocklist-enabled"]' /config/settings.json)
BLOCKLIST_URL=$(jq -r '.["blocklist-url"]' /config/settings.json | sed 's/\&amp;/\&/g')

if [ "${BLOCKLIST_ENABLED:-false}" == "true" -a -n "$BLOCKLIST_URL" ]; then
  mkdir -p /tmp/blocklists
  rm -rf /tmp/blocklists/*
  cd /tmp/blocklists
  wget -q -O blocklist.gz "$BLOCKLIST_URL"
  if [ $? == 0 ]; then
    gunzip *.gz
    if [ $? == 0 ]; then
      chmod go+r *
      rm -rf /config/blocklists/*
      cp /tmp/blocklists/blocklist.gz /config/blocklists/
      s6-svc -h /var/run/s6/services/transmission
    fi
  fi
fi
