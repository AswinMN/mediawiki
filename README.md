# mediawiki

Application Installer
Introduction
The Ansible scripts here runs on a multi Virtual Machine (VM) setup.

All pods run with replication=1. If higher replication is needed, accordingly, the number of VMs needed will be higher.

VM setup
All machines
All machines need to have the following:

User 'centos' with strong password. Same password on all machines.
Password-less sudo su.
Internet connectivity.
Accessible from console via hostnames defined in hosts.ini.
firewalld disabled.
Console
Console machine is the machine from where you run Ansible and other the scripts. You must work on this machine as 'centos' user (not 'root').

Console machine must be accessible with public domain name (e.g. test.abc.com).
Port 80, 443 must be open on the console for external access.
Install Ansible
$ sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
$ sudo yum install ansible
Git clone this repo in user home directory.
$ cd ~/
$ git clone https://github.com/mosip/mosip-infra
$ cd mediawiki/deployment/Working
Exchange ssh keys with all machines. Provide the password for 'aswin'.
$ ./key.sh hosts.ini
Installing Mediawiki
Site settings
In group_vars/all.yml, set the following:

Change domain_name to domain name of the console machine.
By default the installation scripts will try to obtain fresh SSL certificate for the above domain from Letsencrypt. However, If you already have the same then set the following variables in group_vars/all.yml file:
ssl:
  get_certificate: false
  email: ''
  certificate: <certificate dir>
  certificate_key: <private key path> 
Set private ip address of mzworker0.sb and dmzworker0.sb in group_vars/all.yml:
clusters:
  mz:
    any_node_ip: '<mzworker0.sb ip>'

Network interface
If your cluster machines use network interface other than "eth0", update it in group_vars/mzcluster.yml

network_interface: "eth0"
Shortcut commands
Add the following shortcuts in /home/centos/.bashrc:

alias an='ansible-playbook -i hosts.ini'
alias kc1='kubectl --kubeconfig $HOME/.kube/mzcluster.config'
alias helm1='helm --kubeconfig $HOME/.kube/mzcluster.config'

After adding the above:

  $ source  ~/.bashrc
Install Mediawiki
$ ansible-playbook -i hosts.ini site.yml
or with shortcut command

$ an site.yml
Dashboards
The links to various dashboards are available at

https://< domain name>/index.html
Tokens/passwords to login into dashboards are available at /tmp/ of the console.

For Grafana you may import chart 11074.

Reset
To install fresh, you may want to reset the clusters and persistence data. Run the below script for the same. This is dangerous! The reset script will tear down the clusters and delete all persistence data. Provide 'yes/no' responses to the prompts:

$ an reset.yml
Persistence
All persistent data is available over Network File System (NFS) hosted on the console at location /srv/nfs/. All pods write into this location for any persistent data. You may backup this folder if needed.
