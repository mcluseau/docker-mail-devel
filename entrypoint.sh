#!/bin/ash
set -e

MAIL_ADDRESS="${MAIL_USER}@${MAIL_DOMAIN}"

# postfix
/usr/sbin/postconf -e myhostname=$(hostname)
/usr/sbin/postconf -e myorigin=$MAIL_DOMAIN
/usr/sbin/postconf -e mydomain=$MAIL_DOMAIN
/usr/sbin/postconf -e virtual_mailbox_domains=$MAIL_DOMAIN
/usr/sbin/postconf -e smtp_helo_name='$myhostname.$mydomain'

echo "/.+@.+/ $MAIL_ADDRESS" > /etc/postfix/virtual_regexp
/usr/sbin/postmap /etc/postfix/virtual_regexp

# dovecot
sed -i "s/postmaster@localdomain/${MAIL_ADDRESS}/" /etc/dovecot/conf.d/20-lmtp.conf
echo "${MAIL_ADDRESS}:{plain}${MAIL_PASS}" >/etc/dovecot/users

# start services
stop_services() {
    set -x
    postfix stop
    doveadm stop
}
trap "stop_services" SIGINT SIGTERM SIGHUP

chown vmail:postdrop /mailbox

postfix start-fg &
dovecot -F
