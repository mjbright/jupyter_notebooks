#!/bin/bash

echo
echo "--"
VBoxManage.exe list runningvms

echo
echo "--"
VBoxManage.exe showvminfo Vagrant-2015-Dec-18-Docker_Demo | grep -i port

echo
echo "--"
/d/z/bin/DOCKER/win64/docker-1.9.1.exe -H tcp://127.0.0.1:2200 ps

