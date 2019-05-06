#!/bin/bash

TUESDAY_SERVER=${TUESDAY_SERVER:="localhost:3000"}
host_details=`uname -a`
os_name=`uname -s`
msg=""
package_manager=""
packages_outdated=""

if [ $os_name == "Darwin" ]; then
  command -v brew >/dev/null 2>&1 && is_brew_available=true || { echo "brew is not available"; exit 1; }  
  if [ $is_brew_available ]; then
    package_manager="brew"
    $packages_outdated=`brew outdated`
    if [ ${#packages_outdated}==0 ]; then
      echo "No updates available."
    fi
  fi
fi

if [ $os_name == "Linux" ]; then
  command -v apt >/dev/null 2>&1 && is_apt_available=true || { echo "apt is not available"; exit 1; }
  if [ $is_apt_available ]; then
    package_manager="apt"
    packages_outdated=`apt list --upgradable | sed s/]/''/g | awk '!/List/ {print $1, $2, $6}' | paste -d, -s -`
    if [ ${#packages_outdated}==0 ]; then
      echo "No updates available."
    else
      echo $packages_outdated
      msg = $packages_outdated    
    fi
  fi
fi

curl -XPOST -d "host_details=$host_details&pkgmgr=$package_manager&msg=$packages_outdated" $TUESDAY_SERVER/api
