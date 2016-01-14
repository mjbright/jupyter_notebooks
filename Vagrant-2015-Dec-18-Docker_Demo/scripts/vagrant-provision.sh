#!/bin/bash
#
# provision script; install Jupyter demo images
#
# [NOTE] run by Vagrant; never run on host OS.
#
# @see 
#

export DEBIAN_FRONTEND=noninteractive
#export LC_ALL=en_US.UTF-8
#export LANG=en_US.UTF-8
#export LANGUAGE=en_US.UTF-8

################################################################################
# Functions:

die() {
    echo "$0: die - *" >&2
    exit 1
}

################################################################################
# update packages

echo "Updating apt packages ..."
#sudo apt-get -y update
id
apt-get update
echo "... done"

#sudo apt-get -y -q upgrade
#sudo apt-get -y -q dist-upgrade

# zero out the free space to save space in the final image
#sudo dd if=/dev/zero of=/EMPTY bs=1M
#sudo rm -f /EMPTY

#docker run -p 8888:8888 -v /vagrant:. mjbright/jupyter_all-notebook

EXT_PORT=8888
#PORTS=8888:$EXT_PORT
PORTS=$EXT_PORT:8888
IMAGE="mjbright/jupyter_all-notebook"
echo "Launching notebook as daemon on image <$IMAGE> (locally on port $EXT_PORT)"
docker run -d -it -p $PORTS \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /vagrant:/home/jovyan/work \
           $IMAGE

           #-v /jupyter:jupyter \
           #-v .:/host.h ome \

EXT_PORT=8878
#PORTS=8888:$EXT_PORT
PORTS=$EXT_PORT:8888
IMAGE="jupyter/demo"
echo "Launching notebook as daemon on image <$IMAGE> (locally on port $EXT_PORT)"
docker run -d -it -p $PORTS \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /vagrant:/home/jovyan/work \
           $IMAGE

