vagrant up ldap
vagrant up sp  --no-provision
vagrant provision sp --provision-with base,install 
vagrant up idp 
vagrant provision sp --provision-with metadata

# mirror,base,install
# --no-provision
# vagrant provision idp --provision-with mirror,base,install,metadata
