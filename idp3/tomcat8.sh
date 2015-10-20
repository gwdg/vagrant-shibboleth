r=/vagrant/idp3

cd $r

. ./config

## sudo apt-get install -y openjdk-7-jdk
sudo apt-get install -y tomcat8 # tomcat8-admin
sudo usermod -aG ssl-cert tomcat8
sudo patch /etc/default/tomcat8 etc-default-tomcat8.patch

cd ${DEST}
sudo chown -R tomcat8 metadata logs credentials
sudo chgrp -R tomcat8 conf
sudo chmod -R g+r conf
sudo chown    tomcat8 logs

cd $r

sudo mv /etc/tomcat8/catalina.properties /etc/tomcat8/catalina.properties.old
sudo cp tomcat8/catalina.properties /etc/tomcat8/catalina.properties
sudo patch /etc/tomcat8/server.xml tomcat8/server.xml.patch
sudo patch /etc/tomcat8/context.xml tomcat8/context.xml.patch
sudo cp tomcat8/idp.xml /etc/tomcat8/Catalina/localhost/

TOMCAT_HOME=/usr/share/tomcat8
sudo cp $r/_dl/jstl-1.2.jar ${TOMCAT_HOME}/lib

sudo service tomcat8 restart

