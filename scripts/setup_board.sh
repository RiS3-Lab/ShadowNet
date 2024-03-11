#!/bin/sh
setenforce 0
chmod 777 /dev/tee0
mount -o rw,remount /vendor

