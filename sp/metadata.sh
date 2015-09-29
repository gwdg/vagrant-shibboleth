while true 
do 
  curl -ks -o /etc/shibboleth/partner-metadata.xml https://idp.example.org/idp/profile/Metadata/SAML
  if [ $? -eq 0 ]; then
    cat /etc/shibboleth/partner-metadata.xml | grep Error >/dev/null
    if [ $? -ne 0 ]; then
      echo "downloaded idp metadata"
      break
    fi
  fi
  echo "idp metadata not available / waiting 5 secs and then retry.."
  sleep 5
done
service shibd restart

