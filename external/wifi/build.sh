#!/bin/bash
set -xe

cd "${0%/*}"
pwd

make -C ./hostap/src/ clean
rm -rf ./build
mkdir ./build
cd ./build
gcc -g -c -Wall -Werror -fpic ../hostap/src/common/wpa_ctrl.c ../hostap/src/utils/common.c ../hostap/src/utils/os_unix.c ../extension/extension.c -I ../hostap/src/utils/ -I ../hostap/src -DCONFIG_CTRL_IFACE -DCONFIG_CTRL_IFACE_UNIX
gcc -g -shared -o libwpa.so ./wpa_ctrl.o ./common.o ./os_unix.o ./extension.o

cp ./libwpa.so ../../pharo-vm/lib/pharo/5.0-201806281256/libwpa.so

