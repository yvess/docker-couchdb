FROM klaemo/couchdb
MAINTAINER Yves Serrano <y@yas.ch>
RUN apt-get update && apt-get install -yq \
        openssh-server \
        runit \
        python \
    && rm -rf /var/lib/apt/lists/* && \
    mkdir /root/.ssh && chmod 0700 /root/.ssh && \
    mkdir -p /etc/service-off && \
    mkdir -p /var/run/sshd
COPY ./root/_ssh_insecure/id_rsa ./root/_ssh_insecure/id_rsa.pub /root/.ssh/
RUN cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
COPY entrypoint.sh /entrypoint.sh
COPY etc/service/sshd /etc/service/sshd
COPY etc/service/couchdb /etc/service-off/couchdb
ENV HOME /usr/local/var/lib/couchdb
WORKDIR /usr/local/var/lib/couchdb
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22 5984
