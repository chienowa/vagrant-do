# -*- mode: ruby -*-
# vi: set ft=ruby :

Dotenv.load

# change default provider to digital_ocean
ENV['VAGRANT_DEFAULT_PROVIDER'] = "digital_ocean"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider :digital_ocean do |provider, override|
    override.vm.hostname          = "vagrant-do"
    override.vm.box               = "digital_ocean"
    override.vm.box_url           = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
    override.ssh.username         = ENV['DO_SSH_USERNAME']
    override.ssh.private_key_path = ENV['DO_SSH_KEY']

    provider.token                = ENV['DO_API_TOKEN']
    provider.region               = "sgp1"    
    provider.image                = "CentOS 6.5 x64"
    provider.size                 = "512MB" # 512MB | 1GB | 2GB | 4GB | 8GB | 16GB 
    provider.private_networking   = true
    provider.ca_path              = "/usr/local/share/ca-bundle.crt"
    provider.setup                = true
    provider.ssh_key_name         = ENV['DO_SSH_KEYNAME']

    # disable synced_folder: rsync is not installed on DigitalOcean's base image
    override.vm.synced_folder "./", "/vagrant", disabled: true

  end

  config.vm.provision "ansible" do |ansible|
      ansible.sudo = true
      ansible.playbook = "./provision/files/ansible/mt.yml"
      #ansible.playbook = "./provision/files/ansible/playbook.yml"
  end
  config.ssh.forward_agent = true

end
