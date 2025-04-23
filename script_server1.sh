echo "alterar hostname"
hostnamectl set-hostname LAB-server1

echo "instalando docker"
apt install apt-transport-https ca-certificates curl software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

apt install docker-ce docker-ce-cli containerd.io -y

echo "criação de diretorios"
cd /var/lib/docker/volumes
mkdir data app
cd /var/lib/docker/volumes/app
mkdir _data
cd /var/lib/docker/volumes/app/_data

echo "criando um docker swarm"
docker swarm init
#assim que for criado o docker swarm tem aparecer uma chave onde tem que ser colado nas outras máquinas para
# ser integrada ao cluster " #neste caso
#docker swarm join --token SWMTKN-1-4nhwlsjpbvkzanunymiyigyleqne5ar72lqm7pvu6sgnia0kew-7qqpo4mjubp1dodyohuhbul03 172.19.2.16:2377

echo "montando um serviço de container replicado dentro do closter"
docker service create --name web-server --replicas 3 -dt -p 80:80 --mount type=volume,src=app,dst=/app/ webdevops/php-apache:alpine-php7
#Comando para verificar onde foi replicado o contener
docker service ps web-server

echo"instalando um server hfs"
#server para  fazer a replicação dos  arquivos para os outros nodes do closter

apt install nfs-server -t
echo “ediar o arquivo  exports”
#tem que incluir de forma manual 

echo “/var/lib/docker/volumes/app/_data *(rw,sync,subtree_check)”
nano /etc/exports

echo "comando para exportar para as outras máquinas "
exportfs -ar

echo “criando um diretório para a criação de um proxy”
cd /
mkdir proxy |cd /proxy

echo “criando o file de conf proxy”
#incluir as informações
Touch nginx.conf
ARQUIVO=” nginx.conf " 
echo “http { $ARQUIVO”
echo   “ upstream all {  $ARQUIVO”
echo      “  server 172.19.2.19:80;  $ARQUIVO”
echo      “  server 172.19.2.21:80;  $ARQUIVO”
echo      “  server 172.19.2.22:80;  $ARQUIVO”
echo   “ } $ARQUIVO”
echo   “ server { $ARQUIVO”
echo “ listen 4500;  $ARQUIVO”
echo ‘location / {  $ARQUIVO”
echo           “  proxy_pass http://all/; }}} $ARQUIVO”
echo “events { } $ARQUIVO”

touch dockerfile
ARQUIVO1= “dockerfile”
echo “FROM nginx $ARQUIVO1”
echo “COPY nginx.conf /etc/nginx/nginx.conf $ARQUIVO1”

echo "criando um docker puxando as configurações do repositorio apontado"
docker build -t proxy-app .

echo "para rodar o docker"
docker container run --name my-proxy-app -dti -p 4500:4500 proxy-app
