[![build](https://github.com/fab-infra/docker-vsftpd/actions/workflows/build.yml/badge.svg)](https://github.com/fab-infra/docker-vsftpd/actions/workflows/build.yml)

# vsFTPd Docker image

## Ports

The following ports are exposed by this container image.

| Port | Description |
| ---- | ----------- |
| 21 | FTP port |
| 20000-20100 | Passive port range |

## Environment variables

The following environment variables can be used with this container.

| Variable | Description | Default value |
| -------- | ----------- | ------------- |
| FTP_USERS | FTP user:password pairs (space-separated) | |
| FTP_UID | System user ID | 497 |
| FTP_GID | System group ID | 484 |
| FTP_HOME | Home directory for FTP users | /home/vsftpd |
| VSFTPD_* | Custom vsftpd.conf options | |

## Volumes

The following container paths can be used to mount a dedicated volume or to customize configuration.

| Path | Description |
| ---- | ----------- |
| /etc/vsftpd/vsftpd_user_conf | User-specific configuration directory |
| /home/vsftpd | Home directory for FTP users |
| /var/log/vsftpd.log | Server logs |

## Useful links

- [vsFTPd documentation](https://security.appspot.com/vsftpd.html#docs)
