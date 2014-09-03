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

    # disable synced_folder: rsync is not installed on DigitalOcean's base image
    override.vm.synced_folder "./", "/vagrant", disabled: true

    # provision
    override.vm.provision :shell, path: "./provision/tasks/bootstrap.sh", args: [ENV['DO_SSH_USERNAME']]
    override.vm.provision :file,  source: "./provision/files/.ssh/config", destination: "/home/#{ENV['DO_SSH_USERNAME']}/.ssh/config"
    override.vm.provision :file,  source: "./provision/files/.gitconfig",  destination: "/home/#{ENV['DO_SSH_USERNAME']}/.gitconfig"
    override.vm.provision :file,  source: "./provision/files/ansible/hosts", destination: "/tmp/hosts"
    override.vm.provision :file,  source: "./provision/files/ansible/default.vcl", destination: "/tmp/default.vcl"
    override.vm.provision :file,  source: "./provision/files/ansible/etc-sysconfig-varnish", destination: "/tmp/etc-sysconfig-varnish"
    override.vm.provision :file,  source: "./provision/files/ansible/simpleweb.yml", destination: "/tmp/simpleweb.yml"
    override.vm.provision :file,  source: "./provision/files/ansible/wordpress.yml", destination: "/tmp/wordpress.yml"
    override.vm.provision :file,  source: "./provision/files/ansible/varnish.yml", destination: "/tmp/varnish.yml"


    override.vm.provision :shell, inline: "chmod 700 /home/#{ENV['DO_SSH_USERNAME']}/.ssh"
    override.vm.provision :shell, inline: "chmod 600 /home/#{ENV['DO_SSH_USERNAME']}/.ssh/config"
    override.vm.provision :shell, inline: "chmod 644 /home/#{ENV['DO_SSH_USERNAME']}/.gitconfig"
    override.vm.provision :shell, inline: "cd /tmp ; ansible-playbook simpleweb.yml -i hosts --connection=local"
    #override.vm.provision :shell, inline: "cd /tmp ; ansible-playbook wordpress.yml -i hosts --connection=local"
    #override.vm.provision :shell, inline: "cd /tmp ; ansible-playbook varnish.yml -i hosts --connection=local"

  end

  config.ssh.forward_agent = true

end
