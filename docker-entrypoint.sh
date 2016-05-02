#!/bin/bash
set -e

if [ "$1" = 'couchdb' ]; then
  # SET DEFAULT VALUES IF NOT SET
  COUCHDB_DATA=${COUCHDB_DATA:-/var/services/couchdb}
  COUCHDB_LOG=${COUCHDB_LOG:-/var/services/couchdb/log}
  COUCHDB_LOGFILE="$COUCHDB_LOG/couchdb.${HOSTNAME}.log"
  COUCHDB_ADMIN=${COUCHDB_ADMIN:-admin}
  COUCHDB_ADMINPASS=${COUCHDB_ADMINPASS:-admin}
  COUCHDB_LOCAL_HTTPD=${COUCHDB_LOCAL_HTTPD:-}
  COUCHDB_LOCAL_HTTPD_GLOBAL_HANDLERS=${COUCHDB_LOCAL_HTTPD_GLOBAL_HANDLERS:-}
  COUCHDB_LOCAL_VHOSTS=${COUCHDB_LOCAL_VHOSTS:-}

  # MAKE DIRS RUN / ETC / COUCHDB
  mkdir -p /var/run/couchdb "$COUCHDB_DATA" "$COUCHDB_LOG"

  # SET ENV VARS IN LOCAL.INI
  if grep -qv -e "-COUCHDB_DATA-" /etc/couchdb/local.ini; then
    echo "update local.ini"
    sed -i \
      -e "s#-COUCHDB_DATA-#${COUCHDB_DATA}#" \
      -e "s#-COUCHDB_LOGFILE-#${COUCHDB_LOGFILE}#" \
      -e "s#-COUCHDB_ADMIN-#${COUCHDB_ADMIN}#" \
      -e "s#-COUCHDB_ADMINPASS-#${COUCHDB_ADMINPASS}#" \
      -e "s#-COUCHDB_LOCAL_HTTPD-#${COUCHDB_LOCAL_HTTPD}#" \
      -e "s#-COUCHDB_LOCAL_HTTPD_GLOBAL_HANDLERS-#${COUCHDB_LOCAL_HTTPD_GLOBAL_HANDLERS}#" \
      -e "s#-COUCHDB_LOCAL_VHOSTS-#${COUCHDB_LOCAL_VHOSTS}#" \
      /etc/couchdb/local.ini
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

  cd "$COUCHDB_DATA"
  HOME="$COUCHDB_DATA" su couchdb -c /usr/bin/couchdb couchdb
fi

exec "$@"
