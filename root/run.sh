#!/bin/bash

# Check environment
if  [ ! -n "$FTP_USERS" ]; then
    echo "Environment variable 'FTP_USERS' must be set (user1:password1 user2:password2 ...)"
    exit 1
fi

# Create virtual users
echo "${FTP_USERS//[ :]/$'\n'}" | db_load -T -t hash /etc/vsftpd/virtual_users.db

# Set system user UID/GID
[ -z "$FTP_UID" ] || usermod -u "$FTP_UID" ftp
[ -z "$FTP_GID" ] || groupmod -g "$FTP_GID" ftp

# Process environment variables
echo "Processing environment variables ..."
while IFS='=' read -r k v; do
    if [[ "$k" =~ [a-z][a-z0-9_]+ ]]; then
        if grep -q "^$k=" "/etc/vsftpd.conf"; then
            echo "- Updating option: $k=$v"
            sed -ri "s#^$k=.*#$k=$v#g" "/etc/vsftpd.conf"
        else
            echo "- Adding option: $k=$v"
            echo "$k=$v" >> "/etc/vsftpd.conf"
        fi
    fi
done < <(env | sort)

# Configure shutdown handler
trap 'kill $(jobs -p)' SIGINT SIGTERM

# Show logs
touch /var/log/vsftpd.log
tail -f /var/log/vsftpd.log &

# Start server
echo "Starting vsftpd"
/usr/sbin/vsftpd /etc/vsftpd.conf &

# Wait for shutdown
PID=$!
wait $PID
