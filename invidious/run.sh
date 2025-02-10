#!/bin/bash
set -e

echo "[i] generating trusted token..."
TRUSTED_TOKEN_TXT=$(docker run quay.io/invidious/youtube-trusted-session-generator)
echo "[+] got: $TRUSTED_TOKEN_TXT"


echo "[i] cloning invidious git"
tmp_dir=$(mktemp -d)
git clone https://github.com/iv-org/invidious.git "$tmp_dir/invidious"

DOMAIN="example.org"
RANDOM_HMAC_KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 64)
VISITOR_DATA=$(echo "$TRUSTED_TOKEN_TXT" | awk -F': ' '/^visitor_data:/ {print $2}')
PO_TOKEN=$(echo "$TRUSTED_TOKEN_TXT" | awk -F': ' '/^po_token:/ {print $2}')
echo "[i] preparing docker-compose ($VISITOR_DATA / $PO_TOKEN)..."
cat docker-compose.yml.template \
	| sed "s#{my_hmac_key}#$RANDOM_HMAC_KEY#g" \
	| sed "s#{visitor_data}#$VISITOR_DATA#g" \
	| sed "s#{po_token}#$PO_TOKEN#g" \
	| sed "s#{domain}#$DOMAIN#g" \
	> "$tmp_dir/invidious/docker-compose.yml"

cd "$tmp_dir/invidious"

echo "[i] pulling images"
docker-compose pull
echo "[i] uping invidious docker..."
docker-compose up
