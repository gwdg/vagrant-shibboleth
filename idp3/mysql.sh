export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< 'mysql-server mysql-server/root_password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password'
apt-get install -y mysql-server mysql-server-5.5 mysql-server-core-5.5  mysql-client-5.5 mysql-common libmysql-java 
mysql <<EOF
SET NAMES 'utf8';
SET CHARACTER SET utf8;
CHARSET utf8;
CREATE DATABASE IF NOT EXISTS shibboleth CHARACTER SET=utf8;
USE shibboleth;
CREATE TABLE IF NOT EXISTS shibpid (
  localEntity TEXT NOT NULL,
  peerEntity TEXT NOT NULL,
  principalName VARCHAR(255) NOT NULL DEFAULT '',
  localId VARCHAR(255) NOT NULL,
  persistentId VARCHAR(36) NOT NULL,
  peerProvidedId VARCHAR(255) DEFAULT NULL,
  creationDate timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  deactivationDate TIMESTAMP NULL DEFAULT NULL,
  KEY persistentId (persistentId),
  KEY persistentId_2 (persistentId, deactivationDate),
  KEY localEntity (localEntity(16), peerEntity(16), localId),
  KEY localEntity_2 (localEntity(16), peerEntity(16),
    localId, deactivationDate)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE USER 'shibboleth'@'localhost' IDENTIFIED BY 'GEHEIM';
GRANT ALL PRIVILEGES ON shibboleth.* TO 'shibboleth'@'localhost';
FLUSH PRIVILEGES;
EOF

