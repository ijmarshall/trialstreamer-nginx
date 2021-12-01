#!/bin/sh

OPTS=$CMD

if [ -z "$OPTS" ]
then
    OPTS=$1
fi

email="sebastian.galvez@unholster.com"

case "$OPTS" in

print-version)
    echo "Certbot ready"
    certbot --version
    ;;

init)
    echo "Generating dummy certificates"
    mkdir -p /etc/letsencrypt/live/ieai.aws.northeastern.edu
    openssl req -x509 -nodes -newkey rsa:4096 -days 1 \
    -keyout '/etc/letsencrypt/live/ieai.aws.northeastern.edu/privkey.pem' \
    -out '/etc/letsencrypt/live/ieai.aws.northeastern.edu/fullchain.pem' \
    -subj '/CN=ieai.aws.northeastern.edu'
    ;;

remove-cert)
    echo "Deleting dummy certificates for ieai.aws.northeastern.edu"
    rm -Rf /etc/letsencrypt/live/ieai.aws.northeastern.edu && \
    rm -Rf /etc/letsencrypt/archive/ieai.aws.northeastern.edu && \
    rm -Rf /etc/letsencrypt/renewal/ieai.aws.northeastern.edu.conf
    ;;

create-cert)
    echo "Generating SSL certificates"
    certbot certonly --webroot -w /var/www/certbot \
    --email $email \
    -d ieai.aws.northeastern.edu \
    -d *.ieai.aws.northeastern.edu \
    --rsa-key-size 4096 \
    --agree-tos \
    --force-renewal
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
