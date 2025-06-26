#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

read -p "Mail address: " EMAIL

if [[ -z "$EMAIL" ]]; then
  echo "No address, read the README..."
  exit 1
fi

SERVERS=(
  "keys.openpgp.org"
  "keyserver.ubuntu.com"
  "keys.mailvelope.com"
  "pgp.mit.edu"
)

TIMEOUT=15

echo "Searching for PGP Keys for: $EMAIL"
echo "----------------------------------------"

for SERVER in "${SERVERS[@]}"; do
  echo "Searching $SERVER ..."
  RESPONSE=$(curl --max-time $TIMEOUT -s "https://$SERVER/pks/lookup?op=get&search=$EMAIL")

  if [[ $? -ne 0 ]]; then
    echo "No response from $SERVER"
    echo
    continue
  fi

  KEY=$(echo "$RESPONSE" | sed -n '/<pre>/,/<\/pre>/p' | sed 's/<[^>]*>//g')

  if [[ -z "$KEY" ]]; then
    KEY="$RESPONSE"
  fi

  KEY=$(echo "$KEY" | sed 's/^[[:space:]]\+//')

  if echo "$KEY" | grep -q "BEGIN PGP PUBLIC KEY BLOCK"; then
    echo "Key found on $SERVER:"
    echo "----------------------------------------"
    echo "$KEY" | sed -n '/-----BEGIN PGP PUBLIC KEY BLOCK-----/,/-----END PGP PUBLIC KEY BLOCK-----/p'
    echo "----------------------------------------"
    echo
    echo
  else
    echo "No Key found on $SERVER"
  fi

  echo
done
