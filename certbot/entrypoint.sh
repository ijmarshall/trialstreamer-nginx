#!/bin/sh

OPTS=$CMD

if [ -z "$OPTS" ]
then
    OPTS=$1
fi

case "$OPTS" in

  print-version)
      echo "Certbot ready"
      certbot --version
      ;;

  init)
      if [ ! -e "/etc/letsencrypt/options-ssl-nginx.conf" ] || [ ! -e "/etc/letsencrypt/ssl-dhparams.pem" ]; then
        echo "### Downloading recommended TLS parameters ..."
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "/etc/letsencrypt/options-ssl-nginx.conf"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "/etc/letsencrypt/ssl-dhparams.pem"
        echo
      fi
      mkdir -p /etc/letsencrypt/live/robotreviewer.net
      if [ ! -e "/etc/letsencrypt/live/robotreviewer.net/privkey.pem" ] || \
         [ ! -e "/etc/letsencrypt/live/robotreviewer.net/fullchain.pem" ] ; then
        echo "Generating dummy certificates"
        openssl req -x509 -nodes -newkey rsa:4096 -days 1 \
        -keyout '/etc/letsencrypt/live/robotreviewer.net/privkey.pem' \
        -out '/etc/letsencrypt/live/robotreviewer.net/fullchain.pem' \
        -subj '/CN=robotreviewer.net'
      else
        echo "Initial certificates already are created. First remove them with 'remove-cert' command to be able to re-generate them."
      fi
      ;;

  remove-cert)
      echo "Deleting dummy certificates for robotreviewer.net"
      if [ -d "/etc/letsencrypt/live/robotreviewer.net/" ] || \
         [ -d "/etc/letsencrypt/archive/robotreviewer.net/" ] || \
         [ -d "/etc/letsencrypt/renewal/robotreviewer.net/" ] ; then
        rm -Rf /etc/letsencrypt/live/robotreviewer.net && \
        rm -Rf /etc/letsencrypt/archive/robotreviewer.net && \
        rm -Rf /etc/letsencrypt/renewal/robotreviewer.net.conf
        echo "Done."
      else
        echo "Certificates folder does not exist. Aborting..."
      fi
      ;;
  create-cert)
      echo "Generating SSL certificates"
      if [ "$CERTBOT_EMAIL" = "" ]; then echo "Error: missing variable CERTBOT_EMAIL" && exit 1; fi
      echo "Generating demo.ieai.robotreviewer.net certificate." 
      certbot certonly --webroot -w /var/www/certbot \
      --email "$CERTBOT_EMAIL" \
      -d demo.ieai.robotreviewer.net \
      --rsa-key-size 4096 \
      --agree-tos \
      --force-renewal \
      --non-interactive \
      --preferred-challenges http
      echo "Generating trialstreamer.ieai.robotreviewer.net certificate."
      certbot certonly --webroot -w /var/www/certbot \
      --email "$CERTBOT_EMAIL" \
      -d trialstreamer.ieai.robotreviewer.net \
      --rsa-key-size 4096 \
      --agree-tos \
      --force-renewal \
      --non-interactive \
      --preferred-challenges http
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
