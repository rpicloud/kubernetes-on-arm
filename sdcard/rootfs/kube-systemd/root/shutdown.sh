#!/bin/bash
echo "Shutting down"
# Delete replication controllers, deployments and services (in default namespace)
kubectl delete rc $(kubectl get rc | awk '{print $1}' | tail -n +2 | awk 'BEGIN{ORS=" "}1')
kubectl delete svc $(kubectl get rc | awk '{print $1}' | tail -n +2 | awk 'BEGIN{ORS=" "}1')

kubectl delete svc $(kubectl get deployments | awk '{print $1}' | tail -n +2 | awk 'BEGIN{ORS=" "}1')
kubectl delete deployments $(kubectl get deployments | awk '{print $1}' | tail -n +2 | awk 'BEGIN{ORS=" "}1')

echo
echo "Shutting down DNS, registry and heapster"
kubectl delete svc kube-dns registry monitoring-influxdb monitoring-grafana heapster kubernetes-dashboard --namespace=kube-system
kubectl delete rc registry kube-dns-v8 heapster influxdb-grafana kubernetes-dashboard --namespace=kube-system

sleep 80

# Kill workers
base_ip=$(ip -4 -o addr show dev eth0| awk '{split($4,a,"/");print a[1]}')
base_ip="${base_ip::-1}"

echo
echo "Disable node ${base_ip}"2
ssh root@"${base_ip}"2 "kube-config disable-node"

echo
echo "Disable node ${base_ip}"3
ssh root@"${base_ip}"3 "kube-config disable-node"

echo
echo "Disable node ${base_ip}"4
ssh root@"${base_ip}"4 "kube-config disable-node"

echo
echo "Disable master (this node)"
kube-config disable-node

sleep 5

echo "Shutting down ${base_ip}"2
ssh root@"${base_ip}"2 "shutdown -h now"

echo
echo "Shutting down ${base_ip}"3
ssh root@"${base_ip}"3 "shutdown -h now"

echo
echo "Shutting down ${base_ip}"4
ssh root@"${base_ip}"4 "shutdown -h now"

echo
echo "Shutting down master (this node) - bye"
shutdown -h now