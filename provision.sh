. ./config

vagrant up ldap --no-provision
vagrant provision ldap --provision-with base,install # debug

vagrant up sp  --no-provision
vagrant provision sp --provision-with base,dev,install,config,eds
SSO=${SSO} vagrant provision sp --provision-with sso

if [ "${IDP2}" == "enabled" ]; then
  vagrant up idp 
  vagrant provision sp --provision-with metadata-idp
fi

if [ "${IDP3}" == "enabled" ]; then
  vagrant up idp3
  vagrant provision sp --provision-with metadata-idp3
fi

