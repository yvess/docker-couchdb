default: build_couchdb

build_couchdb:
	docker build -t yvess/couchdb .
