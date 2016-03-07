#!/bin/sh

case $1 in
  idp)
    xmlstarlet ed -L \
      -d "/_:SPConfig/_:ApplicationDefaults/_:Sessions/_:SSO/@*" \
      -i "/_:SPConfig/_:ApplicationDefaults/_:Sessions/_:SSO" -t attr -n entityID -v "https://idp.example.org/idp/shibboleth" \
      -i "/_:SPConfig/_:ApplicationDefaults/_:Sessions/_:SSO" -t attr -n ECP      -v "true" \
      /etc/shibboleth/shibboleth2.xml 
    ;;
  idp3)
    xmlstarlet ed -L \
      -d "/_:SPConfig/_:ApplicationDefaults/_:Sessions/_:SSO/@*" \
      -i "/_:SPConfig/_:ApplicationDefaults/_:Sessions/_:SSO" -t attr -n entityID -v "https://idp3.example.org/shibboleth" \
      -i "/_:SPConfig/_:ApplicationDefaults/_:Sessions/_:SSO" -t attr -n ECP      -v "true" \
      /etc/shibboleth/shibboleth2.xml 
    ;;
  eds)
    xmlstarlet ed -L \
      -d "/_:SPConfig/_:ApplicationDefaults/_:Sessions/_:SSO/@*" \
      -i "/_:SPConfig/_:ApplicationDefaults/_:Sessions/_:SSO" -t attr -n discoveryProtocol -v "SAMLDS" \
      -i "/_:SPConfig/_:ApplicationDefaults/_:Sessions/_:SSO" -t attr -n discoveryURL      -v "https://sp.example.org/DS/WAYF" \
      -i "/_:SPConfig/_:ApplicationDefaults/_:Sessions/_:SSO" -t attr -n ECP               -v "true" \
      /etc/shibboleth/shibboleth2.xml 
    ;;
  *)
    echo "usage: $0 (idp|idp3|eds)"
    exit 1
esac
service shibd restart
service apache2 reload

