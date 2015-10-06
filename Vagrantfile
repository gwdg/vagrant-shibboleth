Vagrant.configure(2) do |config|

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = false

  config.vm.box = "debian/jessie64"
  
  config.vm.provision "base",    type: "shell", path: "common/base.sh"
  
  config.vm.define "ldap" do |config|
    config.vm.hostname = "ldap.example.org"
    config.vm.provision "install",   type: "shell", path: "ldap/install.sh"
    config.vm.network "private_network", ip: "172.16.80.2"
  end
  
  config.vm.define "sp" do |config|
    config.vm.hostname = "sp.example.org"
    config.vm.provision "install",  type: "shell", path: "sp/install.sh"
    config.vm.provision "eds",      type: "shell", path: "sp/eds.sh"
    config.vm.provision "metadata", type: "shell", path: "sp/metadata.sh"
    config.vm.network "private_network", ip: "172.16.80.3"
  end
    
  config.vm.define "idp" do |config|
    config.vm.hostname = "idp.example.org"
    config.vm.provision "install",  type: "shell", path: "idp/install.sh"
    config.vm.provision "metadata", type: "shell", path: "idp/metadata.sh"
    config.vm.network "private_network", ip: "172.16.80.4"
    config.vm.provider "virtualbox" do |config|
      config.memory = 2048
    end
  end
  
end

