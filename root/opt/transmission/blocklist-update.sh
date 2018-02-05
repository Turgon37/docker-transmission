#!/usr/bin/env sh

JQ_PATH=$(which jq)

blocklist_enabled=$(${JQ_PATH} -r '.["blocklist-enabled"]' /config/settings.json)
blocklist_url=$(${JQ_PATH} -r '.["blocklist-url"]' /config/settings.json | sed 's/\&amp;/\&/g')

if [ "${blocklist_enabled:-false}" == "true" -a -n "$blocklist_url" ]; then
  mkdir -p /tmp/blocklists
  rm -rf /tmp/blocklists/*
  cd /tmp/blocklists
  wget -q -O blocklist.gz "$blocklist_url"
  if [ $? == 0 ]; then
    gunzip *.gz
    if [ $? == 0 ]; then
      chmod go+r *
      rm -rf /config/blocklists/*
      cp /tmp/blocklists/* /config/blocklists/
      killall -SIGHUP transmission-daemon
    fi
  fi
fi
