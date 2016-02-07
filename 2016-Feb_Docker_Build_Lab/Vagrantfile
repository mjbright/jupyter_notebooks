# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below.
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port within the machine
  # from a port on the host machine.
  # In the example below, accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 8888, host: 8880, auto_correct: true
  config.vm.network "forwarded_port", guest: 8878, host: 8870, auto_correct: true
  config.vm.network "forwarded_port", guest: 2375, host: 2400, auto_correct: true

  # Create a private network, which allows host-only access to the machine using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM.
  # The first argument is # the path on the host to the actual folder.
  # The second argument is the path on the guest to mount the folder.
  # And the optional third argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # DONT - Display the VirtualBox GUI when booting the machine
    # vb.gui = true
    vb.gui = false
 
    # Customize the amount of memory on the VM:
    #vb.memory = "1024"
    vb.memory = "8192"

    # TOFIX: VirtualBox Provider:
    # TOFIX: * The following settings shouldn't exist: hostname
    # TOFIX: #vb.hostname = ENV['VAGRANT_INSTALL']
    # TOFIX: vb.hostname = ENV['BOX_FILENAME']

    vb.customize [ "modifyvm", :id,
                   "--name", "Vagrant-2016-Feb_Docker_Build_Lab",
                   "--memory", "2048"
                 ]
  end

  # avoid possible request "vagrant@127.0.0.1's password:" when "up" and "ssh"
  config.ssh.password = "vagrant"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL

  config.vm.provision :shell, :path => "scripts/vagrant-jupyter-provision.sh", :privileged => false
  #config.vm.provision :shell, :path => "scripts/vagrant-docker-provision.sh", :args => "-RC"
  config.vm.provision :shell, :path => "scripts/vagrant-docker-provision.sh"

  # Define a Vagrant Push strategy for pushing to Atlas, other push strategies also available.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

end

