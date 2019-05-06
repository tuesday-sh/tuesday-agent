#!/bin/bash

TUESDAY_SERVER=${TUESDAY_SERVER:="localhost:3000"}
host_details=`uname -a`
os_name=`uname -s`
msg=""
packages_outdated=""

if [ $os_name == "Darwin" ]; then
  echo "MacOS"
  $packages_outdated=`brew outdated`
  if [ ${#packages_outdated}==0 ]; then
    echo "No updates available."
  fi
fi

if [ $os_name == "Linux" ]; then
  command -v apt >/dev/null 2>&1 || { is_apt_available=true }
  if [ $is_apt_available ]; then
    $packages_outdated=`apt list --upgradable | sed s/]/''/g |  awk '!/List/ {print $1, $2, $6}'`
    if [ ${#packages_outdated}==0 ]; then
      echo "No updates available."
    fi
  fi
fi

curl -XPOST -d "host_details=$host_details&msg=$packages_outdated" $TUESDAY_SERVER/api