#!/bin/bash
set -xe

cd "${0%/*}"
pwd

rm -rf ./build
mkdir ./build
cd ./build
gcc -g -c -Wall -Werror -fpic ../usb_wrapper.c
gcc -g -o usb_wrapper ./usb_wrapper.o -lpthread

