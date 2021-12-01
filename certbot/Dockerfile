FROM certbot/certbot

RUN mkdir -p /scripts/
RUN apk --no-cache add curl

COPY ./entrypoint.sh /scripts/entrypoint.sh
RUN chmod +x /scripts/entrypoint.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
