#!/bin/bash

# Enable master
echo "Enabling master node"
kube-config enable-master
echo "Waiting for master to start up..."
sleep 2m

echo
echo "Enabling dns and registry"
kube-config enable-addon dns registry heapster
sleep 1m

base_ip=$(ip -4 -o addr show dev eth0| awk '{split($4,a,"/");print a[1]}')
base_ip="${base_ip::-1}"
echo "Enable worker node  ${base_ip}2 (async)"
ssh root@"${base_ip}"2 "kube-config enable-worker ${base_ip}1"&
echo "Enable worker node  ${base_ip}3 (async)"
ssh root@"${base_ip}"3 "kube-config enable-worker ${base_ip}1"&
echo "Enable worker node  ${base_ip}4 (async)"
ssh root@"${base_ip}"4 "kube-config enable-worker ${base_ip}1"&

echo 'When you see three "Kubernetes worker services enabled" hit CTRL+C'