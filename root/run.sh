#!/bin/bash

# Check environment
if [ ! -n "$FTP_USERS" ]; then
	echo "Environment variable 'FTP_USERS' must be set (user1:password1 user2:password2 ...)"
	exit 1
fi

# Set system user UID/GID
[ -z "$FTP_UID" ] || usermod -u "$FTP_UID" ftp
[ -z "$FTP_GID" ] || groupmod -g "$FTP_GID" ftp

# Set defaults
FTP_HOME=${FTP_HOME:-/home/vsftpd}
if [ -z "$local_root" -a -z "$VSFTPD_local_root" ]; then
	export VSFTPD_local_root="$FTP_HOME/\$USER"
fi

# Create users
echo "${FTP_USERS//[ :]/$'\n'}" | db_load -T -t hash /etc/vsftpd/virtual_users.db
while IFS=':' read -r FTP_USER_NAME FTP_USER_PWD; do
	if [ -n "$FTP_USER_NAME" ]; then
		echo "Creating user $FTP_USER_NAME"
		FTP_USER_HOME="$FTP_HOME/$FTP_USER_NAME"
		mkdir -p "$FTP_USER_HOME"
		chown ${FTP_UID:-ftp}:${FTP_GID:-ftp} "$FTP_USER_HOME"
	fi
done <<< "${FTP_USERS// /$'\n'}"

# Process environment variables
echo "Processing environment variables ..."
while IFS='=' read -r k v; do
	if [[ "$k" =~ ^(VSFTPD_)?[a-z][a-z0-9_]+$ ]]; then
		k=${k//VSFTPD_/}
		if grep -q "^$k=" "/etc/vsftpd.conf"; then
			echo "- Updating option: $k=$v"
			sed -ri "s#^$k=.*#$k=$v#g" "/etc/vsftpd.conf"
		else
			echo "- Adding option: $k=$v"
			echo "$k=$v" >> "/etc/vsftpd.conf"
		fi
	fi
done < <(env | sort)

# Calculate hash of certificate
if [ -n "$VSFTPD_rsa_cert_file" -a -e "$VSFTPD_rsa_cert_file" ]; then
	sha1sum "$VSFTPD_rsa_cert_file" > "/tmp/vsftpd_rsa_cert_file.sha1sum"
fi

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
