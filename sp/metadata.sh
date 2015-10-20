#!/bin/sh

usage()
{
  echo "usage: $0 (+|-) (idp|idp3) [URL]"
  exit 1
}

case $2 in
  idp|idp3)
    file="metadata-$2.xml"
    ;;
  *)
    usage
    ;;
esac  

case $1 in
  \+)
    action=add
    url=$3
    ;; 
  \-)
    action=del
    ;;
  *)
    usage
    ;;
esac

get()
{
  FILE=/etc/shibboleth/$1
  URL=$2
  while true 
  do 
    curl -ks -o $FILE $URL
    if [ $? -eq 0 ]; then
      cat $FILE | grep Error >/dev/null
      if [ $? -ne 0 ]; then
        echo "downloaded idp metadata from $URL to file $FILE"
        break
      fi
    fi
    echo "IdP metadata not available from $URL, waiting 5 secs and then retry.."
    sleep 5
  done
}

add()
{ 
  file=$1
  url=$2
  get $file $url
  xmlstarlet ed -L \
    -d "/_:SPConfig/_:ApplicationDefaults/_:MetadataProvider[@file=\"$file\"]" \
    -a "/_:SPConfig/_:ApplicationDefaults/_:Errors" -t elem -n N -v "" \
    -i //N -t attr -n type -v XML \
    -i //N -t attr -n file -v $file \
    -r //N -v MetadataProvider \
    /etc/shibboleth/shibboleth2.xml
  service shibd restart
}

del()
{
  file=$1
  xmlstarlet ed -L \
    -d "/_:SPConfig/_:ApplicationDefaults/_:MetadataProvider[@file=\"$file\"]" \
    /etc/shibboleth/shibboleth2.xml
}

$action $file $url

