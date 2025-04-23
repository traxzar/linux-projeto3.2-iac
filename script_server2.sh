#!/bin/bash

echo "alterar hostname"
hostnamectl set-hostname LAB-server2

echo "instalando docker"
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

apt install docker-ce docker-ce-cli containerd.io -y

echo "commando para fazer parte do closter"

docker swarm join --token SWMTKN-1-4nhwlsjpbvkzanunymiyigyleqne5ar72lqm7pvu6sgnia0kew-7qqpo4mjubp1dodyohuhbul03 172.19.2.16:2377

#comando para instalar o serviço sfs cliente
apt install nfs-common -y

echo "Este comando precisar ser executada nos outros nodes do cluster exe. server2 e server3"
mount -o v3 172.19.2.16:/var/lib/docker/volumes/app/_data /var/lib/docker/volumes/app/_data

