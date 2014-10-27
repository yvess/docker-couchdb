FROM klaemo/couchdb
MAINTAINER Yves Serrano <y@yas.ch>
RUN apt-get update && apt-get install -yq \
        openssh-server \
        supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd /var/log/supervisor
COPY ./etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir /root/.ssh && chmod 0755 /root/.ssh
COPY ./root/_ssh/insecure_key /root/.ssh/id_rsa
RUN chmod 0600 /root/.ssh/id_rsa
COPY ./root/_ssh/insecure_key.pub /root/.ssh/id_rsa.pub
RUN chown -R root:root /root/.ssh && cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
EXPOSE 22 5984
WORKDIR /root
CMD ["/usr/bin/supervisord"]
