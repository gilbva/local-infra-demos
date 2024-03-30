# -*- mode: ruby -*-
# vi: set ft=ruby :

ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip

$script = <<-SCRIPT
sudo apt update --fix-missing
sudo apt-get remove needrestart -y
sudo apt install -y net-tools iproute2 netcat dnsutils curl iputils-ping iptables nmap tcpdump traceroute
echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.define "master1" do |cfg|
    cfg.vm.box = "bento/ubuntu-22.04"
    cfg.vm.hostname = "kube-master1"
    cfg.vm.network "private_network", ip: "10.10.8.11"

    cfg.vm.provider "libvirt" do |v|
      v.memory = 8192
      v.cpus = 2
    end

    config.vm.provision "shell", inline: $script
  end

  config.vm.define "master2" do |cfg|
    cfg.vm.box = "bento/ubuntu-22.04"
    cfg.vm.hostname = "kube-master2"
    cfg.vm.network "private_network", ip: "10.10.8.12"

    cfg.vm.provider "libvirt" do |v|
      v.memory = 8192
      v.cpus = 2
    end

    config.vm.provision "shell", inline: $script
  end

  config.vm.define "master3" do |cfg|
    cfg.vm.box = "bento/ubuntu-22.04"
    cfg.vm.hostname = "kube-master3"
    cfg.vm.network "private_network", ip: "10.10.8.13"

    cfg.vm.provider "libvirt" do |v|
      v.memory = 8192
      v.cpus = 2
    end

    config.vm.provision "shell", inline: $script
  end

  config.vm.define "worker1" do |cfg|
    cfg.vm.box = "bento/ubuntu-22.04"
    cfg.vm.hostname = "kube-worker1"
    cfg.vm.network "private_network", ip: "10.10.8.21"

    cfg.vm.provider "libvirt" do |v|
      v.memory = 8192
      v.cpus = 2
    end

    config.vm.provision "shell", inline: $script
  end

  config.vm.define "worker2" do |cfg|
    cfg.vm.box = "bento/ubuntu-22.04"
    cfg.vm.hostname = "kube-worker2"
    cfg.vm.network "private_network", ip: "10.10.8.22"

    cfg.vm.provider "libvirt" do |v|
      v.memory = 8192
      v.cpus = 2
    end

    config.vm.provision "shell", inline: $script
  end

  config.vm.define "worker3" do |cfg|
    cfg.vm.box = "bento/ubuntu-22.04"
    cfg.vm.hostname = "kube-worker3"
    cfg.vm.network "private_network", ip: "10.10.8.23"

    cfg.vm.provider "libvirt" do |v|
      v.memory = 8192
      v.cpus = 2
    end

    config.vm.provision "shell", inline: $script
  end
end


