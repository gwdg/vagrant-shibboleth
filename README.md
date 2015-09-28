# Vagrant Shibboleth Development Environment

This environment provides a self-contained sample shibboleth environment comprising
three nodes, namely:

- 'sp.example.org' (Apache 2.4, MySQL, Shibboleth SP 2.5),
- 'idp.example.org' (Apache 2.4, Tomcat 7, Shibboleth IdP Version 2.4.3, uApprove), 
- 'ldap.example.org' (OpenLDAP with sample accounts 'alice', 'bob' and 'robert')

running on Debian/Jessie 64-bit virtual machines (tested on VirtualBox).

During the provisioning process the metadata between IdP and SP are exchanged.

## Prequisites

- Vagrant (tested with Version 1.7.2)
- Provider (e.g. VirtualBox - tested with version 4.3)
- download/unpack tools: curl, unzip

## Getting Started

Bootstrap script installs vagrant hostmanager plugin and 
stages shibboleth-identityprovider and uApprove once.

    $ ./bootstrap.sh

Then, provision the machines:

    $ ./provision.sh

## Test-Drive

    1. In your local hosts web-browser, open 

        'https://sp.example.org/secure-all'

      [Accept this 'insecure' connection - self-signed certificate]
    
      'sp.example.org' will be resolved to the IP of the VM due to hostmanager plugin.


    2. You are redirected to idp.example.org 
      
      [Accept this 'insecure' connection - since this is a self-signed certificate]

       Login as user 'alice' and password 'wonderland'.

    3. You should be successfully authenticated and redirected back to 'sp'.


## Update
    
Edit `idp/config` to specify newer software versions of the IdP 


## Further URLs
    
    https://sp.example.org/secure-all
    https://sp.example.org/cgi-bin/test.py

    https://idp.example.org/idp/Authn/UserPassword
    https://idp.example.org/idp/status
    https://idp.example.org/idp/profile/Status
    http://idp.example.org:8080/manager (u: tomcat, p: tomcat)
    https://idp.example.org/idp/profile/Metadata/SAML

    https://sp.example.org/Shibboleth.sso/Metadata


## Advanced

### Speed up provisioning of Linux VMs

Use 'vagrant-vbguest' to disable virtualbox guest checks.
E.g. 

    vagrant plugin install vagrant-vbguest

Edit '$HOME/.vagrant.d/Vagrantfile':

    Vagrant.configure("2") do |config|

      if Vagrant.has_plugin?("vagrant-vbguest")
        config.vbguest.auto_update = false
      end

    end

With vbguest auto-update disabled and pre-installed basebox, 
the setup of the environment takes approx. 10 minutes (with a host connected to the internet by a fast connection).


## Tested Host Configurations

- Mac OS X 10.8.5, Vagrant 1.7.2, VirtualBox 4.3.26
- Linux/Ubuntu Trusty64, Vagrant 1.7.2, VirtualBox 4.3.10
- Mac OS X 10.10.5, Vagrant 1.7.4, VirtualBox 5.0.4

