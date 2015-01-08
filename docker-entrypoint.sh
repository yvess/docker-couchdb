#!/bin/bash
set -e

if [ "$1" = 'couchdb' ]; then
  # set default values if not set
  COUCHDB_DATA=${COUCHDB_DATA:-/var/services/log/couchdb}
  COUCHDB_LOG=${COUCHDB_LOG:-/var/services/data/couchdb}
  COUCHDB_ADMIN=${COUCHDB_ADMIN:-admin}
  COUCHDB_ADMINPASS=${COUCHDB_ADMINPASS:-admin}
  # make dirs
  if [ ! -d "${COUCHDB_DATA}" ] || [ ! -d "${COUCHDB_LOG}" ]; then
    echo "creating service directories"
    mkdir -p "$COUCHDB_DATA" "$COUCHDB_LOG" /var/run/couchdb
    chown -R couchdb:couchdb "$COUCHDB_DATA" "$COUCHDB_LOG" /var/run/couchdb /etc/couchdb/local.ini
  fi
  # set env vars in local.ini
  if grep -qv -e "-COUCHDB_DATA-" /etc/couchdb/local.ini; then
    # escape / in path for sed
    COUCHDB_DATA_ESC=${COUCHDB_DATA//\//\\/}
    COUCHDB_LOG_ESC=${COUCHDB_LOG//\//\\/}
    sed -i -e "s/-COUCHDB_DATA-/${COUCHDB_DATA_ESC}/" -e "s/-COUCHDB_LOG-/${COUCHDB_LOG_ESC}/" /etc/couchdb/local.ini
    sed -i -e "s/-COUCHDB_ADMIN-/${COUCHDB_ADMIN}/" -e "s/-COUCHDB_ADMINPASS-/${COUCHDB_ADMINPASS}/" /etc/couchdb/local.ini
  fi
  cd "$COUCHDB_DATA"
  HOME="$COUCHDB_DATA" exec su couchdb -c /usr/bin/couchdb couchdb "$@"
fi

exec "$@"
