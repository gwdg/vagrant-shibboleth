Vagrant.configure(2) do |config|

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = false

  config.vm.box = "kaorimatz/debian-8.2-amd64"
  # config.vm.box = "debian/jessie64"
  # DOES NOT WORK: config.vm.synced_folder ".", "/vagrant", type: 'virtualbox'

  config.vm.provision "base",    type: "shell", path: "common/base.sh"

  
  config.vm.define "ldap" do |config|
    config.vm.hostname = "ldap.example.org"
    config.vm.network "private_network", ip: "172.16.80.2"
    config.vm.provision "install",   type: "shell", path: "ldap/install.sh"
    config.vm.provision "debug",     type: "shell", path: "ldap/debug.sh"
  end
  
  config.vm.define "sp" do |config|
    config.vm.hostname = "sp.example.org"
    config.vm.network "private_network", ip: "172.16.80.3"
    config.vm.provision "dev",           type: "shell", path: "sp/dev.sh"
    config.vm.provision "install",       type: "shell", path: "sp/install.sh"
    config.vm.provision "config",        type: "shell", path: "sp/config.sh"
    config.vm.provision "eds",           type: "shell", path: "sp/eds.sh"
    config.vm.provision "sso",           type: "shell", path: "sp/sso.sh",      args: "#{ENV['SSO']}"
    config.vm.provision "metadata-idp",  type: "shell", path: "sp/metadata.sh", args: "+ idp  https://idp.example.org/idp/shibboleth"
    config.vm.provision "metadata-idp3", type: "shell", path: "sp/metadata.sh", args: "+ idp3 https://idp3.example.org/idp/shibboleth"
  end
    
  config.vm.define "idp" do |config|
    config.vm.hostname = "idp.example.org"
    config.vm.network "private_network", ip: "172.16.80.4"
    config.vm.provision "install",  type: "shell", path: "idp/install.sh"
    config.vm.provision "metadata", type: "shell", path: "idp/metadata.sh"
    config.vm.provider "virtualbox" do |config|
      config.memory = 2048
    end
  end

  config.vm.define "idp3" do |config|
    config.vm.hostname = "idp3.example.org"
    config.vm.network "private_network", ip: "172.16.80.5"
    config.vm.provision "install",  type: "shell", path: "idp3/dfn.sh"
    config.vm.provider "virtualbox" do |config|
      config.memory = 2048
    end
  end
  
end

