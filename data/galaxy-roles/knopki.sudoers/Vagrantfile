# -*- mode: ruby -*-
# vi: set ft=ruby ts=2 sw=2 tw=0 et :

role = File.basename(File.expand_path(File.dirname(__FILE__)))

boxes = [
  {:name => "ubuntu-1204", :box => "opscode-ubuntu-12.04", :url => "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box", :ip => '10.0.0.10', :cpu => "50", :ram => "256"},
  {:name => "debian-720", :box => "opscode-debian-7.2.0", :url => "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian_7.2.0_chef-provisionerless.box", :ip => '10.0.0.11', :cpu => "50", :ram => "256"},
]

Vagrant.configure("2") do |config|
  boxes.each do |box|
    config.vm.define box[:name] do |vms|
      vms.vm.box = box[:box]
      vms.vm.box_url = box[:url]
      vms.vm.hostname = "#{role}-#{box[:name]}"

      vms.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--cpuexecutioncap", box[:cpu]]
        v.customize ["modifyvm", :id, "--memory", box[:ram]]
      end

      vms.vm.network :private_network, ip: box[:ip]

      vms.vm.provision :ansible do |ansible|
        ansible.playbook = "#{role}.yml"
        ansible.verbose = false
      end
    end
  end
end
