# Vagrant Shibboleth Development Environment

This environment provides a self-contained sample shibboleth environment comprising
three nodes, namely:

- sp.example.org (Apache 2.4, MySQL, Shibboleth SP 2.5, Shibboleth DS 1.1.0),
- idp.example.org (Apache 2.4, Tomcat 7, Shibboleth IdP Version 2.4.3, uApprove 2.6), 
- ldap.example.org (OpenLDAP with sample accounts 'alice', 'bob' and 'robert')

running on Debian/Jessie 64-bit virtual machines (tested on VirtualBox).

During the provisioning process the metadata between IdP and SP are exchanged.

## Prequisites

- Vagrant 
- Provider (e.g. VirtualBox)
- Host command-line tools (for bootstrap.sh): 
    curl, unzip

## Getting Started

Bootstrap script installs vagrant hostmanager plugin and 
stages shibboleth-identityprovider and uApprove once.

    $ ./bootstrap.sh

All three machines are provisioned via

    $ ./provision.sh

## Test-Drive

1. Service Provider / Unauthenticated
   
   Open the URL https://sp.example.org/secure-all in your web-browser on the host.

   Accept 'insecure' https connection since this is a self-signed certificate.

2. Embedded Discovery Service / Where Are You From (WAYF) page

   You are redirected to the WAYF page at https://sp.example.org/DS/WAYF (using the embedded discovery service)
   where you can choose one IDP.

3. Identity Provider

   You are redirected to https://idp.example.org/idp/Authn/UserPassword.

   Also accept 'insecure' https connection since this is a self-signed certificate.

4. Login
  
   with username ``alice`` and password ``wonderland``.

5. uApprove

   You are about to see the 'Terms of Use' page which you should accept and confirm to see a list of three
   attributes: 'eduPersonEntitlement', 'email' and 'eduPersonScopedAffiliation'.

6. Service Provider / Authenticated

   Finally, you should be successfully authenticated and redirected back to https://sp.example.org/secure-all,
   where you are welcomed by a 'Not found' page (which means 'success').

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
- Windows 10 / Cygwin, Vagrant 1.7.4, VirtualBox 5.0.4

