FROM nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY ./includes/ /etc/nginx/includes/
COPY ./ssl/ /etc/ssl/certs/nginx/
