# FTP server based on openSUSE Leap 15.2
FROM fcrespel/base-image:opensuse15.2

# vsFTPd
RUN zypper in -y db48-utils pam-extra vsftpd &&\
    zypper clean -a

# Files
COPY ./root /
RUN chmod +x /run.sh &&\
    mkdir -p /etc/vsftpd &&\
    mkdir -p /home/vsftpd &&\
	chown ftp:ftp /home/vsftpd

# Ports
EXPOSE 21 20000-20100
