#!/bin/sh

qemu-system-i386\
  -cpu host\
  -m 256M\
  -enable-kvm\
  -drive file=$1,format=raw
