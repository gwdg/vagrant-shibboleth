r=/vagrant/sp
apt-get install -y apache2 libapache2-mod-shib2

openssl req -batch -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/ssl/private/sp.example.org.key \
     -out /etc/ssl/certs/sp.example.org.crt \
     -subj /CN=sp.example.org 2>/dev/null

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/shibboleth/sp-key.pem \
     -out /etc/shibboleth/sp-cert.pem \
     -subj /CN=sp.example.org 2>/dev/null

mkdir -p /var/www/vhosts/sp.example.org

cp $r/apache.conf /etc/apache2/sites-available/sp.conf
cp $r/shibboleth2.xml /etc/shibboleth
a2enmod ssl
# a2enmod shib2
a2ensite sp
service apache2 reload
service shibd restart

