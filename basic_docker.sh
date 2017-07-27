#!bin/bash

# update yum repository
echo " --------------------------------------------------------- "
echo " update the repo "
echo " --------------------------------------------------------- "
yum install -y update

# get the latest repo and install it
echo " --------------------------------------------------------- "
echo " getting docker "
echo " --------------------------------------------------------- "
curl -fsSL https://get.docker.com/ | sh

# start docker
echo " --------------------------------------------------------- "
echo " setting up docker "
echo " --------------------------------------------------------- "
systemctl start docker
systemctl enable docker
usermod -aG docker $(whoami)

echo " --------------------------------------------------------- "
echo " SETUP PORTAINER GUI "
echo " --------------------------------------------------------- "
mkdir /home/portainer
docker run --name portainer -p 9000:9000 -v /home/portainer:/data  -v "/var/run/docker.sock:/var/run/docker.sock" -d portainer/portainer


echo " --------------------------------------------------------- "
echo " SETUP FCREPO "
echo " --------------------------------------------------------- "
# Look at the git_repos dockerfiles fcrepo
docker run -d -p 8080:8080 --name fcrepo -v /home/fcrepo/data:/home/fcrepo4-data -v /home/fcrepo/ingest:/home/ingest fcrepo
