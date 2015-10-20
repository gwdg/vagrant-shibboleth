r=/vagrant/idp3

curl -ks -o /opt/shibboleth-idp/metadata/sp-metadata.xml https://sp.example.org/Shibboleth.sso/Metadata

apt-get install -y xmlstarlet

cd /opt/shibboleth-idp/metadata
mv idp-metadata.xml idp-metadata-no-mdui.xml
. $r/mdui.conf
$r/mdui.sh idp-metadata-no-mdui.xml >idp-metadata.xml

cp $r/logo.jpg /var/www/html

