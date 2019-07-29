#!/bin/bash
set -xe

cd "${0%/*}"
pwd

rm -rf ./build
mkdir ./build
cd ./build
gcc -g -c -Wall -Werror -fpic ../bluetooth_wrapper.c $(pkg-config --cflags --libs dbus-1) 
gcc -g -o bluetooth_wrapper ./bluetooth_wrapper.o -lbluetooth

