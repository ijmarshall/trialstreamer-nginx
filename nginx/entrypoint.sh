#!/bin/sh

echo "Starting Nginx"
nohup sh ./docker-entrypoint.sh nginx -g "daemon off;"

echo "Running crontab for periodical config reloading"
crontab /etc/cron.d/crontab
nohup cron
