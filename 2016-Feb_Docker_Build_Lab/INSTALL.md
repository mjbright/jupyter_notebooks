
Lab Installation
================

The notebooks of this lab are runnable in a Jupyter installation with the bash_kernel installed.

Although that is not the subject of this lab, if you want to create your own environment in which to run this lab with Docker components already installed (and even Jupyter/bash_kernel)


Docker Lab
============

This lab has been run on RHEL7.1 and Ubunty/trusty64.

You should be able to run this lab in most Linux environments which already have
- Docker clients installed
- Git installed

RHEL 7.1 Specifics
------------------
For static binary compilation (linking) of a C program you will require the glibc-static package.
Install this using the command:

    yum install -y glibc-static

For the **'February 2016 Docker Build Lab'**
--------------------------------------------
- **refer to the PDF instructions [here](https://raw.githubusercontent.com/mjbright/jupyter_notebooks/master/2016-Feb_Docker_Build_Lab/2016-Feb_Docker_Build_Lab.pdf) (http://bit.ly/1QF0XaH)**
- you do not need to **(must not)** follow the below installation procedure.

Installation of this lab environment (optional)
============

If you want to install this lab environment yourself as a Vagrant image
(on any platform with VirtualBox and Vagrant already installed),
you can do this following these instructions.

It installs extra components not need to simply participate in the lab.

Contents
--------

This environment will install
- A Ubuntu/trusty64 image (Vagrant box)
- Download and install Python3 (Anaconda3 distribution)
- Install the Jupyter notebook
- Install the bash_kernel for Jupyter
- Install Docker engine, compose, machine clients

Installing
----------
Checkout this repository to an appropriate directory.

```bash
    git clone https://github.com/mjbright/jupyter_notebooks/tree/master/2016-Feb_Docker_Build_Lab DockerLab
    cd DockerLab

    vagrant up

    
```

