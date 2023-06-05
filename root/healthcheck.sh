#!/bin/bash

# Check certificate hash
HASH_CERT_FILE="/tmp/vsftpd_rsa_cert_file.sha1sum"
if [ -e "$HASH_CERT_FILE" ]; then
	sha1sum --check --status "$HASH_CERT_FILE" || exit 1
fi

# Check port
echo "QUIT" | curl -sSf -o /dev/null "telnet://localhost:21" || exit 1
