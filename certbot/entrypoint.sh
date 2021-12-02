#!/bin/sh

OPTS=$CMD

if [ -z "$OPTS" ]
then
    OPTS=$1
fi

# Disable staging mode here
certbot_staging=$CERTBOT_STAGING
certbot_email="$CERTBOT_EMAIL"

case "$OPTS" in

print-version)
    echo "Certbot ready"
    certbot --version
    ;;

init)
    if [ ! -e "/etc/letsencrypt/conf/options-ssl-nginx.conf" ] || [ ! -e "/etc/letsencrypt/ssl-dhparams.pem" ]; then
      echo "### Downloading recommended TLS parameters ..."
      curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "/etc/letsencrypt/options-ssl-nginx.conf"
      curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "/etc/letsencrypt/ssl-dhparams.pem"
      echo
    fi
    mkdir -p /etc/letsencrypt/live/ieai.aws.northeastern.edu
    if [ ! -e "/etc/letsencrypt/ieai.aws.northeastern.edu/privkey.pem" ] || \
       [ ! -e "/etc/letsencrypt/ieai.aws.northeastern.edu/fullchain.pem" ] ; then
      echo "Generating dummy certificates"
      openssl req -x509 -nodes -newkey rsa:4096 -days 1 \
      -keyout '/etc/letsencrypt/live/ieai.aws.northeastern.edu/privkey.pem' \
      -out '/etc/letsencrypt/live/ieai.aws.northeastern.edu/fullchain.pem' \
      -subj '/CN=ieai.aws.northeastern.edu'
    else
      echo "Initial certificates already are created. Please remove them with remove-cert command to
       re-generate them."
    fi
    ;;

remove-cert)
    echo "Deleting dummy certificates for ieai.aws.northeastern.edu"
    if [ -d "/etc/letsencrypt/live/ieai.aws.northeastern.edu/" ] || \
       [ -d "/etc/letsencrypt/archive/ieai.aws.northeastern.edu/" ] || \
       [ -d "/etc/letsencrypt/renewal/ieai.aws.northeastern.edu/" ] ; then
      rm -Rf /etc/letsencrypt/live/ieai.aws.northeastern.edu && \
      rm -Rf /etc/letsencrypt/archive/ieai.aws.northeastern.edu && \
      rm -Rf /etc/letsencrypt/renewal/ieai.aws.northeastern.edu.conf
      echo "Done."
    else
      echo "Certificates folder does not exist. Aborting..."
    fi
    ;;
create-cert)
    echo "Generating SSL certificates"
    if [ $certbot_email = "" ]; then echo "Error: missing variable CERTBOT_EMAIL" && exit 1; fi
    if [ $certbot_staging != 0 ]; then staging_arg="--staging"; fi
    certbot certonly --webroot -w /var/www/certbot \
    --email $certbot_email \
    -d robotreviewer.ieai.aws.northeastern.edu \
    -d trialstreamer.ieai.aws.northeastern.edu \
    --rsa-key-size 4096 \
    --agree-tos \
    --force-renewal \
    --preferred-challenges http \
    $staging_arg
    ;;

renew)
    echo "Renewing SSL certificates"
    certbot renew
    ;;

renew-loop)
    /bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'
    ;;
*)
    if [ ! -z "$(which $1)" ]
    then
        $@
    else
        echo "Invalid command"
        exit 1
    fi
    ;;
esac
