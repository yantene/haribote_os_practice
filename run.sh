#!/bin/sh

qemu-system-x86_64\
  -cpu host\
  -m 256M\
  -enable-kvm\
  -drive file=$1,format=raw
