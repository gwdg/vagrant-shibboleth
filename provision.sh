vagrant up ldap
vagrant up sp  --no-provision
vagrant provision sp --provision-with base,install 
vagrant up idp 
vagrant provision sp --provision-with metadata

