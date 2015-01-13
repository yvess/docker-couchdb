#!/bin/bash
set -e

if [ "$1" = 'couchdb' ]; then
  # set default values if not set
  COUCHDB_DATA=${COUCHDB_DATA:-/var/services/data/couchdb}
  COUCHDB_LOG=${COUCHDB_LOG:-/var/services/log/couchdb/couchdb.log}
  COUCHDB_ADMIN=${COUCHDB_ADMIN:-admin}
  COUCHDB_ADMINPASS=${COUCHDB_ADMINPASS:-admin}
  # make dirs
  if [ ! -d "${COUCHDB_DATA}" ] || [ ! -d "${COUCHDB_LOG}" ]; then
    echo "creating service directories"
    mkdir -p "$COUCHDB_DATA" "$COUCHDB_LOG" /var/run/couchdb
    chown -R couchdb:couchdb "$COUCHDB_DATA" "$COUCHDB_LOG" \
      /var/run/couchdb /etc/couchdb/local.ini
    if find /etc/couchdb/local.d/* -maxdepth 0 -type f; then
      chown -R couchdb:couchdb /etc/couchdb/local.d/*
    fi
  fi
  # set env vars in local.ini
  if grep -qv -e "-COUCHDB_DATA-" /etc/couchdb/local.ini; then
    echo "update local.ini"
    # escape / in path for sed
    COUCHDB_DATA_ESC=${COUCHDB_DATA//\//\\/}
    COUCHDB_LOG_ESC=${COUCHDB_LOG//\//\\/}
    sed -i -e "s/-COUCHDB_DATA-/${COUCHDB_DATA_ESC}/" \
      -e "s/-COUCHDB_LOG-/${COUCHDB_LOG_ESC}/" /etc/couchdb/local.ini
    sed -i -e "s/-COUCHDB_ADMIN-/${COUCHDB_ADMIN}/" \
      -e "s/-COUCHDB_ADMINPASS-/${COUCHDB_ADMINPASS}/" /etc/couchdb/local.ini
  fi
  # append config from child container
  if [ -f "/tmp/local.append.ini" ]; then
    echo "append local.append.ini"
    cat /tmp/local.append.ini >> /etc/couchdb/local.ini && rm /tmp/local.append.ini
  fi
  cd "$COUCHDB_DATA"
  HOME="$COUCHDB_DATA" su couchdb -c /usr/bin/couchdb couchdb
fi

exec "$@"
