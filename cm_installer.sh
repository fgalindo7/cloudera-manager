#!/bin/bash

main() {
  # Obtain internal IP and FQDN of the worker-nodes
  echo ""
  echo "Have you configured your server for Cloudera Manager?"
  echo -n "[y/n]: "
  read user_ans

  user_ans="${user_ans,,}"

  if [[ $user_ans != 'y' ]]; then
    echo ""
    echo "Execute the following command before installing Cloudera Manager:"
    echo " bash cm_sys_config.sh"
    exit
  fi

  echo ""
  echo -n "Enter the number of worker-nodes in your cluster: "
  read nodes

  # Only numbers
  while ! [[ "$nodes" =~ ^[0-9]+$ ]]; do
    echo -n "Enter the number of worker-nodes in your cluster [integer]: "
    read nodes
  done

  node_counter=1
  while [[ $nodes > 0 ]]; do
    echo ""
    echo -n "Enter the FQDN of node $node_counter: "
    read node_fqdn
    echo -n "Enter the internal IP of node $node_counter: "
    read node_internal_ip

    while ! valid_ip $node_internal_ip; do
      echo -n "Enter a valid internal IP for node $node_counter: "
      read node_internal_ip
    done

    # Remove protocols and www
    node_fqdn="${node_fqdn#*\:\/\/}"
    node_fqdn="${node_fqdn#www.}"

    # get substring with hostname
    node_hostname="${node_fqdn%%.*}"

    echo "Confirm that node $node_counter values are correct."
    echo "  Hostname: $node_hostname"
    echo "  FQDN: $node_fqdn"
    echo "  Internal IP: $node_internal_ip"
    echo -n "[y] to confirm, [e/n] to edit: "
    read confirmation

    confirmation="${confirmation,,}"

    if [[ $confirmation == "y" || $confirmation == "yes" ]]; then
      # Add nodes to the /etc/hosts file
      sudo su -c 'echo "$* # Added by Devops" >> /etc/hosts' root -- bash "$node_internal_ip $node_fqdn $node_hostname"
      node_counter=$((node_counter+1))
      nodes=$((nodes-1))
    fi
  done

  # Silent installer
  cm_silent_install
}


function cm_silent_install() {
  cd /opt; sudo ./cloudera-manager-installer.bin --i-agree-to-all-licenses \
  --noprompt --noreadme --nooptions
}


function valid_ip() {
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


main "$@"
