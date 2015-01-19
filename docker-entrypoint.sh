#!/bin/bash
set -e

if [ "$1" = 'couchdb' ]; then
  # set default values if not set
  COUCHDB_DATA=${COUCHDB_DATA:-/var/services/data/couchdb}
  COUCHDB_LOG=${COUCHDB_LOG:-/var/services/log/couchdb/couchdb.log}
  COUCHDB_ADMIN=${COUCHDB_ADMIN:-admin}
  COUCHDB_ADMINPASS=${COUCHDB_ADMINPASS:-admin}
  # make dirs run / etc / couchdb
  mkdir -p /var/run/couchdb "$COUCHDB_DATA" "$COUCHDB_LOG"

  # set env vars in local.ini
  if grep -qv -e "-COUCHDB_DATA-" /etc/couchdb/local.ini; then
    echo "update local.ini"
    sed -i -e "s#-COUCHDB_DATA-#${COUCHDB_DATA_ESC}#" \
      -e "s#-COUCHDB_LOG-#${COUCHDB_LOG_ESC}#" /etc/couchdb/local.ini
    sed -i -e "s#-COUCHDB_ADMIN-#${COUCHDB_ADMIN}#" \
      -e "s#-COUCHDB_ADMINPASS-#${COUCHDB_ADMINPASS}#" /etc/couchdb/local.ini
  fi
  # append config from child container
  if [ -f "/tmp/local.append.ini" ]; then
    echo "append local.append.ini"
    cat /tmp/local.append.ini >> /etc/couchdb/local.ini && rm /tmp/local.append.ini
  fi
  # make sure everything is owned by couchdb
  chown -R couchdb:couchdb "$COUCHDB_DATA" "$COUCHDB_LOG" /var/run/couchdb /etc/couchdb/local.ini
  if find /etc/couchdb/local.d/* -maxdepth 0 -type f; then
    chown -R couchdb:couchdb /etc/couchdb/local.d/*
  fi
  cd "$COUCHDB_DATA"
  HOME="$COUCHDB_DATA" su couchdb -c /usr/bin/couchdb couchdb
fi

exec "$@"
