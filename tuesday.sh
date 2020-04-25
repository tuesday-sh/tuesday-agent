#!/usr/bin/env bash

TUESDAY_SERVER=${TUESDAY_SERVER:-localhost:3000}
AGENT_VERSION=0.0.1
host_details=$(uname -a)
os_name=$(uname -s)
msg=''
package_manager=''
packages_outdated=''
now=$(date +%s)

if [[ $os_name == Darwin ]]; then
  command -v brew >/dev/null &&
    is_brew_available=true ||
    { echo "brew is not available"; exit 1; }
  if [[ $is_brew_available ]]; then
    package_manager=brew
    packages_outdated=$(brew outdated)
    if [[ -z $packages_outdated ]]; then
      echo "No updates available."
    fi
  fi
fi

if [[ $os_name == Linux ]]; then
  command -v apt >/dev/null && is_apt_available=true ||
    { echo "apt is not available"; }
  command -v yum >/dev/null &&
    is_yum_available=true ||
    { echo "yum is not available"; }

  # if [[ ! $is_apt_available && ! $is_yum_available ]]; then
  #   echo "No supported package manager found [apt, yum]"
  #   exit 1
  # fi

  if [[ $is_apt_available ]]; then
    package_manager=apt
    packages_outdated=$(
      apt list --upgradable |
        sed s/]/''/g |
        awk '!/List/ {print $1, $2, $6}' |
        paste -d, -s -
    )
    if [[ -z $packages_outdated ]]; then
      echo "No updates available."
    else
      echo "$packages_outdated"
      msg=$packages_outdated
    fi
  fi

  if [[ $is_yum_available ]]; then
    package_manager=yum
    packages_outdated=$(
      yum check-update -q |
        awk '!/^$/ {print $1, $2}' |
        paste -d, -s -
      )
    if [[ -z $packages_outdated ]]; then
      echo "No updates available."
    else
      echo "$packages_outdated"
      msg=$packages_outdated
    fi
  fi
fi
params="host=$host_details&v=$AGENT_VERSION&time=$now&pkgmgr=$package_manager&msg=$packages_outdated"
echo $params
curl -XPOST -d $params $TUESDAY_SERVER/api