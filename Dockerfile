FROM alpine:3.8

ARG TRANSMISSION_VERSION

LABEL maintainer='Pierre GINDRAUD <pgindraud@gmail.com>'

ENV SMTP_PORT=25
ENV SMTP_STARTTLS=no
ENV SMTP_SSL=no
#ENV SMTP_USERNAME=SASL_USERNAME
#ENV SMTP_PASSWORD=SASL_PASSWORD
#ENV SMTP_SERVER

# Install dependencies
RUN apk --no-cache add \
      curl \
      jq \
      ssmtp \
      transmission-daemon=$TRANSMISSION_VERSION

# Create the working filetree
RUN mkdir -p \
      /config \
      /downloads/complete \
      /downloads/incomplete \
      /watch \
    && chown transmission:transmission \
      /config \
      /downloads \
      /downloads/complete \
      /downloads/incomplete \
      /watch \
    && chgrp transmission /etc/ssmtp /etc/ssmtp/ssmtp.conf \
    && chmod g+w /etc/ssmtp /etc/ssmtp/ssmtp.conf

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091/tcp 51413/tcp 51413/udp
VOLUME ["/config", "/downloads", "/watch"]

WORKDIR /downloads
USER transmission:transmission

HEALTHCHECK --interval=5s --timeout=3s --retries=3 \
    CMD curl --connect-timeout 1 --max-time 2 --silent --fail http://localhost:9091 || exit 1

CMD ["/start.sh"]
