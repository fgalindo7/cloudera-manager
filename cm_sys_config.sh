#!/bin/bash

sudo sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo systemctl disable firewalld
sudo yum install -y wget
cd /opt; sudo wget http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin
sudo chmod u+x /opt/cloudera-manager-installer.bin

# Transparent Huge Page Compaction if enabled can cause significant performance problems
sudo su -c "echo never > /sys/kernel/mm/transparent_hugepage/defrag" root
sudo su -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled" root
# Add these commands to an init script such as /etc/rc.local so it will be set on system reboot
echo "if test -f /sys/kernel/mm/transparent_hugepage/enabled; then echo never > /sys/kernel/mm/transparent_hugepage/enabled; echo never > /sys/kernel/mm/transparent_hugepage/defrag; fi" >> /etc/rc.local


# Cloudera recommends setting /proc/sys/vm/swappiness to a maximum of 10
# Set the value for the running system
if [[ "$(cat /proc/sys/vm/swappiness)" > 10 ]];
  then sudo bash -c 'echo 10 > /proc/sys/vm/swappiness';
fi

# Backup sysctl.conf
sudo cp -p /etc/sysctl.conf /etc/sysctl.conf.`date +%Y%m%d-%H:%M`

# Set the value in /etc/sysctl.conf to keep after reboot
sudo sh -c 'echo "" >> /etc/sysctl.conf'
sudo sh -c 'echo "# Devops" >> /etc/sysctl.conf'
sudo sh -c 'echo "# Set swappiness to 10 as recommended by Cloudera Manager" >> /etc/sysctl.conf'
sudo sh -c 'echo "vm.swappiness = 10" >> /etc/sysctl.conf'
# Change swapiness
sudo sysctl vm.swappiness=10

# Reboot is needed in order to disable selinux
echo ""
echo "Your system has been configured."
echo "To install Cloudera Manager, a system reboot is necessary."
echo -n "Proceed with reboot [y/n]?: "
read confirmation

confirmation="${confirmation,,}"

if [[ $confirmation == "y" || $confirmation == "yes" ]]; then
  sudo reboot now
else
  echo "Reboot your system before running the Cloudera Manager installer."
fi
