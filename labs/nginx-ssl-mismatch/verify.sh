#!/bin/bash
if ! systemctl is-active --quiet nginx; then echo "FAILURE: Nginx not running"; exit 1; fi
CERT_MOD=$(openssl x509 -noout -modulus -in /etc/nginx/ssl/server.crt 2>/dev/null)
KEY_MOD=$(openssl rsa -noout -modulus -in /etc/nginx/ssl/server.key 2>/dev/null)
if [ "$CERT_MOD" != "$KEY_MOD" ]; then echo "FAILURE: SSL mismatch"; exit 1; fi
echo "SUCCESS: SSL match"; exit 0
