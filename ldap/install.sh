DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils
ldapadd -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: `slappasswd -s secret`

dn: olcDatabase={0}config,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: `slappasswd -s secret`
EOF
ldapadd -x -D cn=admin,dc=example,dc=org -w secret -f /vagrant/ldap/dit.ldif

