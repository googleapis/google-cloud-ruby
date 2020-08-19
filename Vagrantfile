# -*- mode: ruby -*-
# vi: set ft=ruby :

$grpc = <<SCRIPT
# Install grps
echo "deb http://http.debian.net/debian jessie-backports main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update -y
sudo apt-get install libgrpc-dev -y --force-yes
SCRIPT

$gcloud = <<SCRIPT
sudo apt-get install curl -y
curl https://sdk.cloud.google.com | bash
SCRIPT

$rvm = <<SCRIPT
# Install RVM and ruby 2.3
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install ruby-2.3
rvm --default use 2.3

# Install git and bundler and grpc gem
sudo apt-get install git -y
gem install --no-document bundler grpc
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "vmware_fusion" do |v, override|
    override.vm.box = "helderco/trusty64"
  end

  config.ssh.forward_agent = true

  config.vm.provision "shell", inline: $grpc
  config.vm.provision "shell", inline: $gcloud, privileged: false
  config.vm.provision "shell", inline: $rvm, privileged: false
end
