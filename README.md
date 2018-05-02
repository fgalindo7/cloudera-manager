# Cloudera manager installer

Cloudera Manager requires System configurations and a reboot before the installer can run.
To use these scripts, you need to perform the following steps:

 (1) sudo yum install -y git
 (2) git clone https://github.com/fgalindo7/cloudera-manager.git
 (3) bash cloudera-manager/cm_sys_config.sh
	This will reboot your system

 (4) bash cloudera-manager/cm_installer.sh
