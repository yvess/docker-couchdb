#!/bin/bash
set -e

if [ "$1" = 'couchdb' ]; then
  # SET DEFAULT VALUES IF NOT SET
  COUCHDB_DATA=${COUCHDB_DATA:-/var/services/data/couchdb}
  COUCHDB_LOG=${COUCHDB_LOG:-/var/services/log/couchdb/couchdb.log}
  COUCHDB_ADMIN=${COUCHDB_ADMIN:-admin}
  COUCHDB_ADMINPASS=${COUCHDB_ADMINPASS:-admin}

  # MAKE DIRS RUN / ETC / COUCHDB
  mkdir -p /var/run/couchdb "$COUCHDB_DATA" "$COUCHDB_LOG"

  # SET ENV VARS IN LOCAL.INI
  if grep -qv -e "-COUCHDB_DATA-" /etc/couchdb/local.ini; then
    echo "update local.ini"
    sed -i -e "s#-COUCHDB_DATA-#${COUCHDB_DATA}#" \
      -e "s#-COUCHDB_LOG-#${COUCHDB_LOG}#" /etc/couchdb/local.ini
    sed -i -e "s#-COUCHDB_ADMIN-#${COUCHDB_ADMIN}#" \
      -e "s#-COUCHDB_ADMINPASS-#${COUCHDB_ADMINPASS}#" /etc/couchdb/local.ini
  fi

  # APPEND CONFIG FROM CHILD CONTAINER
  if [ -f "/tmp/local.append.ini" ]; then
    echo "append local.append.ini"
    cat /tmp/local.append.ini >> /etc/couchdb/local.ini && rm /tmp/local.append.ini
  fi

  # RUN COUCHDB ENTRY SCRIPT
  if [ -f "/entrypoint-couchdb.sh" ]; then
    /entrypoint-couchdb.sh
  fi

  # MAKE SURE EVERYTHING IS OWNED BY COUCHDB
  chown -R couchdb:couchdb "$COUCHDB_DATA" "$COUCHDB_LOG" /var/run/couchdb /etc/couchdb/local.ini
  if [ -f /etc/couchdb/local.d/* ]; then
    chown -R couchdb:couchdb /etc/couchdb/local.d/*
  fi

  # CLEANUP
  rm -Rf /root/build

  cd "$COUCHDB_DATA"
  HOME="$COUCHDB_DATA" su couchdb -c /usr/bin/couchdb couchdb
fi

exec "$@"
