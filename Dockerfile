# FTP server based on openSUSE Leap 15.3
FROM ghcr.io/fab-infra/base-image:opensuse15.3

# vsFTPd
RUN zypper in -y db48-utils pam-extra vsftpd &&\
	zypper clean -a

# Files
COPY ./root /
RUN mkdir -p /etc/vsftpd &&\
	mkdir -p /home/vsftpd &&\
	chown ftp:ftp /home/vsftpd

# Ports
EXPOSE 21 20000-20100
