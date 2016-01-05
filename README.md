# Vagrant Shibboleth Development Environment

This environment provides a self-contained runnable shibboleth environment comprising
four nodes, namely:

- idp3.example.org (Shibboleth IdP v3.2, Tomcat 8, Apache 2.4)
- idp.example.org (Shibboleth IdP v2.4.3, uApprove 2.6, Tomcat 7, Apache 2.4), 
- sp.example.org (Shibboleth SP 2.5, Shibboleth Embedded Discovery 1.1.0, Apache 2.4),
- ldap.example.org (OpenLDAP)

running on Debian/Jessie 64-bit virtual machines.

During the provisioning process the metadata between IdPs and the SP are exchanged.

## Prequisites

- Vagrant 
- Hypervisor / Vagrant Provider (currently VirtualBox was tested)
- Host command-line tools (for bootstrap.sh): 
    curl, unzip

## Getting Started

**RUN ONCE PER HOST:** 

Execute script to install vagrant hostmanager plugin which also modifies the `sudoers` file of your host to grant vagrant/hostmanager access to
dynamically manipulate the `hosts` file on your host.

    $ ./install-vagrant-plugins.sh

**RUN ONCE PER CLEAN PROJECT:** 

Execute bootstrap script to stage `eds`, `shibboleth-identityprovider v2` and `uApprove` sources, and `shibboleth-identityprovider v3` sources.


    $ ./bootstrap.sh

**Then**

Run script to provision all machines.

    $ ./provision.sh

## Test-Drive

1. Service Provider / Unauthenticated
   
   On your host, open the URL https://sp.example.org/secure-all in your favorite web-browser.

   Please accept 'insecure' https connection since this is a self-signed certificate.

2. Embedded Discovery Service / Where Are You From (WAYF) page

   You are redirected to the WAYF page at https://sp.example.org/DS/WAYF (using the embedded discovery service)
   where you can choose between sample IdP v2 and IdP v3 instances.

3. Identity Provider

   You are redirected to https://idp.example.org/idp/Authn/UserPassword or 
   https://idp3.example.org/idp/profile/SAML2/Redirect/SSO...?executione1s1.
   
   Please also accept 'insecure' https connection since this is a self-signed certificate.

4. Login
  
   with username ``alice`` and password ``wonderland``.

5. IdP v2: uApprove

   You are about to see the 'Terms of Use' page which you should accept and confirm to see a list of three
   attributes: 'eduPersonEntitlement', 'email' and 'eduPersonScopedAffiliation'.

   (Detailed configuration for IdP v3 is work-in-progress.)

6. Service Provider / Authenticated

   Finally, you should be successfully authenticated and redirected back to https://sp.example.org/secure-all,
   where you are welcomed by a 'Not found' page (which means 'success').

## Fine-tune Installation 
  
In the default setup both IdP v2 and IdP v3 nodes are provisioned and the SP is configured to use a WAYF EDS.
If you only need one particular IdP or want SP to pass control to a specific IdP for login, please
edit `config` before running `provision.sh`.

Edit `idp3/config`, `sp/config` `idp/config` to update software versions of EDS, IdP v2 and v3 (needed at bootstrap time).

## Advanced Topics

### Troubleshooting

#### Guest VM system-time out of sync 

If you see
on IdP v3 (`idp3.example.org`):

    Error Message: Web Login Service - Stale Request

or on IdP v2 (`idp.example.org`):

    Error Message: Message did not meet security requirements

it might be that the system time of your SP and/or IdPs is out of sync.

Diagnostics:
Check the system time of the guest VMs.
For example on idp.example.org:  `/opt/shibboleth/logs/idp-process.log`

~~~
16:35:55.406 - WARN [org.opensaml.common.binding.security.IssueInstantRule:108] - Message was expired: message issue time was '2015-10-19T14:27:55.000Z', message expired at: '2015-10-19T14:33:55.000Z', current time: '2015-10-19T16:35:55.406+02:00'
16:35:55.412 - WARN [edu.internet2.middleware.shibboleth.idp.profile.saml2.SSOProfileHandler:406] - Message did not meet security requirements
org.opensaml.ws.security.SecurityPolicyException: Message was rejected due to issue instant expiration
~~~

Fix:

Try reload the SP. E.g. `vagrant reload sp` and test again.

### Speed up provisioning 

#### Disable virtualbox guest check

Install Vagrant plugin 'vagrant-vbguest' to disable virtualbox guest checks.
E.g. 

    $ vagrant plugin install vagrant-vbguest

Enable plugin by editing `$HOME/.vagrant.d/Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|
  
  # ...

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end
  
  # ...

end
```

With vbguest auto-update disabled and pre-installed basebox, 
the setup of the environment takes approx. 10 minutes (with a host connected to the internet by a fast connection).

#### Use http cache (for apt-get etc..)

Install Vagrant plugin `vagrant-proxyconf` that injects proxy settings to the guest

    $ vagrant plugin install vagrant-proxyconf

Install a http proxy cache.
For example, Polipo on Mac OS X using MacPorts:

    $ sudo port install polipo
    $ sudo launchctl load -w /opt/local/etc/LaunchDaemons/org.macports.Polipo/org.macports.Polipo.plist

Enable plugin by editing `$HOME/.vagrant.d/Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|
  
  # ...

  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = "http://10.0.2.2:8123/"
    config.proxy.https    = "http://10.0.2.2:8123/"
    config.proxy.no_proxy = "localhost,127.0.0.1,.example.com,.example.org"
  end

  # ...
  
end  
```

## Tested Host Configurations

- Mac OS X 10.8.5, Vagrant 1.7.2, VirtualBox 4.3.26
- Linux/Ubuntu Trusty64, Vagrant 1.7.2, VirtualBox 4.3.10
- Mac OS X 10.10.5, Vagrant 1.7.4, VirtualBox 5.0.4
- Windows 10 / Cygwin, Vagrant 1.7.4, VirtualBox 5.0.4

## Developer Notes: Available URLs
    
    https://sp.example.org/secure-all
    https://sp.example.org/cgi-bin/test.py
 
    https://idp.example.org/idp/Authn/UserPassword
    https://idp.example.org/idp/status
    https://idp.example.org/idp/profile/Status
    http://idp.example.org:8080/manager (u: tomcat, p: tomcat)
    https://idp.example.org/idp/profile/Metadata/SAML

    https://sp.example.org/Shibboleth.sso/Metadata
    https://sp.example.org/Shibboleth.sso/Status
    https://sp.example.org/Shibboleth.sso/Session

    https://idp3.example.org/idp/
    https://idp3.example.org/idp/status
    https://idp3.example.org/idp/shibboleth


