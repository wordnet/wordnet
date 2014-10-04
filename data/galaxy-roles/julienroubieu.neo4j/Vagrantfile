# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.
  # 7474 is the default Neo4j port. The port here must be the same as the one in vars/vagrant.yml
  config.vm.network :forwarded_port, guest: 7474, host: 7474

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # The IP here should be the same as in vagrant_host
  config.vm.network :private_network, ip: "10.0.0.74"
  
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "vagrant.yml"
    ansible.inventory_path = "vagrant_host"
    ansible.sudo = true
    ansible.verbose = "vv"
  end

end
