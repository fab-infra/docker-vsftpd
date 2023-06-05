# FTP server based on openSUSE Leap 15.4
FROM ghcr.io/fab-infra/base-image:opensuse15.4

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

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=5 CMD [ "/healthcheck.sh" ]
