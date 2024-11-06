from alpine:3.20.3

env MAIL_DOMAIN=localdomain.test \
    MAIL_USER=devel \
    MAIL_PASS=devel

volume /mailbox
expose 25 110 143

run apk add --no-cache iproute2 postfix dovecot dovecot-pop3d dovecot-lmtpd

copy postfix/ /etc/postfix/
copy dovecot/ /etc/dovecot/conf.d/

entrypoint ["ash","/entrypoint.sh"]
copy entrypoint.sh /
