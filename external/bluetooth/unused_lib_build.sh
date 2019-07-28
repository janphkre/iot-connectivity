#!/bin/bash
set -xe

cd "${0%/*}"
pwd

rm -rf ./build
mkdir ./build
cd ./build
gcc -g -c -Wall -Werror -fpic ../lib_bluetooth.c -I ../opensmalltalk-vm/platforms/Cross/vm -I ../opensmalltalk-vm/platforms/minheadless/common -I ../opensmalltalk-vm/ -I ../opensmalltalk-vm/src/vm -I ../opensmalltalk-vm/platforms/minheadless/unix -I ../opensmalltalk-vm/platforms/Cross/plugins/SocketPlugin
gcc -g -shared -o libbluez.so ./lib_bluetooth.o

cp ./libbluez.so ../../../pharo-vm/lib/pharo/5.0-201806281256/libbluez.so

