.PHONY:

couchdb_version = 1.6.1

default: build_couchdb

build_couchdb:
	docker build -t yvess/couchdb:$(couchdb_version) .
