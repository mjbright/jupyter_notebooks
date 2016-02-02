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

########################################
# Download Anaconda3 for linux:

URL=https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda3-2.4.1-Linux-x86_64.sh

wget -O Anaconda3_installer.sh $URL

chmod a+x Anaconda3_installer.sh

# Install Anaconda3 to ~/anaconda3 in batch mode:
./Anaconda3_installer.sh -b -p ~/anaconda3

{ echo;
  echo "# Add anaconda3 to PATH:
  echo "export PATH=~/anaconda3/bin:\$PATH";
  echo;
} >> .bashrc

########################################
# Install jupyter:

conda install -y jupyter

########################################
# Install the bash_kernel:

pip install bash_kernel

python -m bash_kernel.install

########################################
# Replace 'old' conda/pexpect v3.3 with 'new' pip/pexpect v4.0.1
# Necessary to allow correct treatment of multiple command lines in a cell

conda remove -y pexpect

pip install pexpect


########################################
# Setup handy link to jupyter start script:

ln -s /vagrant/scripts/start_NATIVE_jupyter.sh ./jupyter.sh

########################################
# Install pandoc/latex tools for PDF printing of notebooks:

# Disabled as long to run, problematic - best to just print to PDF from host
# apt-get install -y pandoc linuxdoc-tools-latex

