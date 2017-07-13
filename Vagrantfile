# -*- mode: ruby -*-
# # vi: set ft=ruby :

#https://github.com/devopsgroup-io/vagrant-hostmanager

require 'fileutils'
require 'open-uri'
require 'tempfile'
require 'yaml'

$controller_count = 1
$controller_vm_memory = 1024
$worker_count = 1
$worker_vm_memory = 1024

CONFIG = File.expand_path("config.rb")
if File.exist?(CONFIG)
  require CONFIG
end

if $worker_vm_memory < 1024
  puts "Workers should have at least 1024 MB of memory"
end

CONTROLLER_CLUSTER_IP="10.3.0.1"

CONTROLLER_CLOUD_CONFIG_PATH = File.expand_path("controller-install.sh")
WORKER_CLOUD_CONFIG_PATH = File.expand_path("worker-install.sh")

def controllerIP(num)
  return "172.17.4.#{num+100}"
end

def workerIP(num)
  return "172.17.4.#{num+200}"
end

controllerIPs = [*1..$controller_count].map{ |i| controllerIP(i) } <<  CONTROLLER_CLUSTER_IP


Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  
  config.vm.provider :virtualbox do |vb|
    vb.cpus = 1
    vb.gui = false
  end

  hosts = Tempfile.new('hosts')

  hosts.write("127.0.0.1 localhost\n")

  (1..$controller_count).each do |i|
    vm_name = "c%d" % i
    ip = controllerIP(i)
    hosts.write("#{ip} #{vm_name}\n")
  end

  (1..$worker_count).each do |i|
    vm_name = "w%d" % i
    ip = workerIP(i)
    hosts.write("#{ip} #{vm_name}\n")
  end

  hosts.close

  (1..$controller_count).each do |i|
    config.vm.define vm_name = "c%d" % i do |controller|

      controller.vm.hostname = vm_name

      controller.vm.provider :virtualbox do |vb|
        vb.memory = $controller_vm_memory
      end

      controllerIP = controllerIP(i)
      controller.vm.network :private_network, ip: controllerIP
      controller.vm.provision :shell, :inline => "export IP_ADDRESS=#{controllerIP}", :privileged => true

      controller.vm.provision :shell, inline: "> /etc/profile.d/myvars.sh", run: "always"
      controller.vm.provision :shell, inline: "echo \"export IP_ADDRESS=#{controllerIP}\" >> /etc/profile.d/myvars.sh", run: "always"

      controller.vm.provision :file, :source => CONTROLLER_CLOUD_CONFIG_PATH, :destination => "/tmp/vagrantfile-user-data"
      controller.vm.provision :file, :source => hosts, :destination => "/tmp/hosts"
      controller.vm.provision :shell, :inline => "mv /tmp/hosts /etc/hosts", :privileged => true
      controller.vm.provision :shell, :inline => "chmod +x /tmp/vagrantfile-user-data", :privileged => true
      controller.vm.provision :shell, :inline => "/tmp/vagrantfile-user-data", :privileged => true
    end
  end

    (1..$worker_count).each do |i|
    config.vm.define vm_name = "w%d" % i do |worker|
      worker.vm.hostname = vm_name
      worker.vm.provider :virtualbox do |vb|
        vb.memory = $worker_vm_memory
      end

      workerIP = workerIP(i)
      worker.vm.network :private_network, ip: workerIP

      worker.vm.provision :shell, inline: "> /etc/profile.d/myvars.sh", run: "always"
      worker.vm.provision :shell, inline: "echo \"export IP_ADDRESS=#{workerIP}\" >> /etc/profile.d/myvars.sh", run: "always"

      worker.vm.provision :file, :source => WORKER_CLOUD_CONFIG_PATH, :destination => "/tmp/vagrantfile-user-data"
      worker.vm.provision :file, :source => hosts, :destination => "/tmp/hosts"
      worker.vm.provision :shell, :inline => "mv /tmp/hosts /etc/hosts", :privileged => true
      worker.vm.provision :shell, :inline => "chmod +x /tmp/vagrantfile-user-data", :privileged => true
      worker.vm.provision :shell, :inline => "/tmp/vagrantfile-user-data", :privileged => true
    end
  end  
  
end
