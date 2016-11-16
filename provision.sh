. ./config

vagrant up ldap --no-provision
vagrant provision ldap --provision-with base,install # debug

vagrant up sp  --no-provision
vagrant provision sp --provision-with base,dev,install,config,eds
SSO=${SSO} vagrant provision sp --provision-with sso

if [ "${SP2}" == "enabled" ]; then
  vagrant up sp2  --no-provision
  vagrant provision sp2 --provision-with base,dev,install,config,eds
  SSO=${SSO} vagrant provision sp2 --provision-with sso
fi

if [ "${IDP2}" == "enabled" ]; then
  vagrant up idp 
  vagrant provision sp --provision-with metadata-idp
  if [ "${SP2}" == "enabled" ]; then
    vagrant provision idp --provision-with metadata-sp2
  fi
fi

if [ "${IDP3}" == "enabled" ]; then
  vagrant up idp3
  vagrant provision sp --provision-with metadata-idp3
  if [ "${SP2}" == "enabled" ]; then
    vagrant provision idp3 --provision-with metadata-sp2
  fi
fi


