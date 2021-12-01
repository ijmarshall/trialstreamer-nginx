FROM nginx

RUN apt-get update && apt-get -y install cron && rm -rf /etc/cron.*/*

COPY ./crontab /etc/cron.d/crontab
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/includes/ /etc/nginx/includes/
COPY ./entrypoint.sh /scripts/entrypoint.sh

RUN chmod 0644 /etc/cron.d/crontab
RUN chmod +x /scripts/entrypoint.sh

ENTRYPOINT ["./scripts/entrypoint.sh"]
