#!/bin/bash

# Default: testing (release candidates):
[ -z "$1" ] && set -- -RC

MACHINE_RC=v0.6.0-rc2
MACHINE_RC_URL=https://github.com/docker/machine/releases/download/$MACHINE_RC/docker-machine-`uname -s`-`uname -m`


COMPOSE_RC=1.6.0-rc2
COMPOSE_RC_URL=https://github.com/docker/compose/releases/download/$COMPOSE_RC/docker-compose-`uname -s`-`uname -m`

################################################################################
# Functions:
die() {
    echo "$0: die - $*" >&2
    exit 1
}

################################################################################
# Args:
while [ ! -z "$1" ];do
    case $1 in
        -RC|-rc)
            VERSION="RC";
            URL=https://test.docker.com;;
        -st*)
            VERSION="stable";
            URL=https://get.docker.com;;
        -dev*)
            VERSION="dev";
            URL=https://dev.docker.com;;

        *) die "Unknown option <$1>";;
    esac
    shift
done

################################################################################
# Main:

SCRIPT="./INSTALL_docker_${VERSION}.sh"

echo "Downloading script <$SCRIPT> ..."

# To avoid curl error:
#    curl: (77) error setting certificate verify locations:
sudo mkdir -p /etc/pki/tls/certs/
sudo cp /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt

#
# Install Docker engine:
#
curl -sSL $URL > $SCRIPT &&
    echo "Downloading script <$SCRIPT> for '$RC' from $URL ..." &&
    chmod +x $SCRIPT &&
    sudo bash $SCRIPT &&
    echo "Starting Docker service" &&
    sudo service docker start &&
    echo "Running Docker hello-world" &&
    sudo docker run hello-world

#
# Add vagrant to the docker group:
# - remember if in shell as vagrant - you need to logout/in first ...
sudo usermod -aG docker vagrant

#
# Install Docker machine:
#
curl -L $MACHINE_RC_URL | sudo tee /usr/local/bin/docker-machine >/dev/null
sudo chmod +x /usr/local/bin/docker-machine

#
# Install Docker compose:
#
curl -L $COMPOSE_RC_URL | sudo tee /usr/local/bin/docker-compose >/dev/null
sudo chmod +x /usr/local/bin/docker-compose



