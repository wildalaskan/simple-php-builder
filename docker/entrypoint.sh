#!/usr/bin/env bash
set -e

function set_nginx_listen() {
  USE_SSL="${USE_SSL:-false}"
  if [[ "${USE_SSL}" == "true" ]]; then
    sed -i "s|{{LISTEN}}|443 ssl|g
            s|#ssl_certificate|ssl_certificate|g
            s|#ssl_certificate_key|ssl_certificate_key|g
            " /etc/nginx/http.d/default.conf
  else
    sed -i "s|{{LISTEN}}|80|g
            s|#ssl_certificate.*$||g
            s|#ssl_certificate_key.*$||g
            " /etc/nginx/http.d/default.conf
  fi
}

function set_nginx_php_server() {
  if [[ "${OCTANE_START}" == "true" ]]; then
    sed -i "s|{{PHP_SERVER}}|@octane|g" /etc/nginx/http.d/default.conf
  else
    sed -i "s|{{PHP_SERVER}}|/index.php?\$query_string|g" /etc/nginx/http.d/default.conf
  fi
}

set_nginx_listen
set_nginx_php_server

if [ "$1" != "" ]; then
  exec "$@"
else
  exec /usr/bin/supervisord -n -c /etc/supervisord.conf
fi
