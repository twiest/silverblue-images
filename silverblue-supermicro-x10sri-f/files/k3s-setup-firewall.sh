#!/bin/bash

# Only do this if you want to be able to run kubectl from other hosts (I don't)
#firewall-cmd --permanent --add-port=6443/tcp #apiserver

# These are necessary according to the docs:
# https://docs.k3s.io/advanced#red-hat-enterprise-linux--centos
firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 #pods
firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 #services
firewall-cmd --reload
