FROM ubuntu:14.04
MAINTAINER Yves Serrano <y@yas.ch>

ENV DEBIAN_FRONTEND=noninteractive
ADD etc/ /etc/
RUN locale-gen en_US.UTF-8 && \
    apt-get update && \
    apt-get install -yq software-properties-common && \
    add-apt-repository ppa:couchdb/stable -y && apt-get update -yq && \
    apt-get install -yq couchdb pwgen curl && \
    apt-get purge -y --auto-remove software-properties-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ADD docker-entrypoint.sh /entrypoint.sh
ADD local.ini /etc/couchdb/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["couchdb"]
EXPOSE 5984
