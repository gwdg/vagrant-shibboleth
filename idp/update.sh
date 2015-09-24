#!/bin/sh
r=/vagrant/idp
. $r/common
X=`which java`
JAVA_HOME=`readlink -f $X | sed "s:bin/java::"`

# JAVA_HOME="/usr"
export JAVA_HOME

WEBAPP_DIR=$r/webapp

( cd ${IDP_INSTALL} && sudo JAVA_HOME="${JAVA_HOME}" ./install.sh \
  -noinput \
  -Dwebapp.dir=${WEBAPP_DIR} \
  -Didp.home.input=${DEST} \
  -Didp.hostname.input=${HOST}.${SCOPE} \
  -Didp.keystore.pass=none \
  -Didp.scope=${SCOPE} \
  -Dinstall.config=no
)

