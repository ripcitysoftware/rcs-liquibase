FROM kilna/liquibase-postgres

MAINTAINER Chris Maki <chris.maki@ripcitysoftware.com>

VOLUME /source_root

COPY run.sh /run.sh
RUN chmod 755 /run.sh

CMD [ "/run.sh" ]