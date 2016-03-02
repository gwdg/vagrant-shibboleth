#!/bin/sh
debconf-set-selections <<EOF
slapd slapd/password1 password secret
slapd slapd/internal/adminpw password secret
slapd slapd/password2 password secret
slapd slapd/internal/generated_adminpw password secret
slapd slapd/domain string example.org
slapd shared/organization string example.org
EOF
DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils
ldapadd -x -D cn=admin,dc=example,dc=org -w secret -f /vagrant/ldap/dit.ldif
