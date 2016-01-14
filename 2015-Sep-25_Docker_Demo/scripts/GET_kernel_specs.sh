#!/bin/bash

HOST=localhost
PORT=8887

wget -O - http://${HOST}:${PORT}/api/kernelspecs

wget -O - http://${HOST}:${PORT}/api/kernelspecs/bash


