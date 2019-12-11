FROM centos:7

MAINTAINER Ricardo Santana <rsantana@kenos.com.br>

RUN yum -y install git mercurial which \
  && git clone https://github.com/frej/fast-export.git /opt/fast-export \
  && cd /opt/fast-export \
  && git checkout tags/v180317 \
  && git config core.ignoreCase false \
  && echo 'alias hg-fast-export="/opt/fast-export/hg-fast-export.sh"' >> ~/.bashrc \
  && rm -rf /var/cache/yum

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "%%CMD%%" ]
