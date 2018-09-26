#!/bin/bash
#
# Author:: Sander Botman (<sbotman@schubergphilis.com>)
# Copyright:: Copyright (c) 2013 Sander Botman.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

your_org="Your Organization Name Here"

which dialog >/dev/null 2>&1
if [ ! "$?" == "0" ]; then echo "This script needs the 'dialog' application. Please install this first. Eg: yum install dialog."; exit 1; fi


function display_gauge() {
(
  echo $1
  echo "###"
  echo "$1 %"
  echo "###"
) |
dialog --title "Retrieving cosmic information" --backtitle "${your_org}" --gauge "Please wait ...." 10 60 0
}


function choose_option() {
  MENU_OPTIONS=
  COUNT=0

  while IFS= read -r line
  do
    COUNT=$[COUNT+1]
    option=`echo $line | sed 's/\s/_/g'`
    MENU_OPTIONS="${MENU_OPTIONS}${COUNT} ${option} "
  done <<< "${!1}"

  cmd=(dialog --title "$2" --backtitle "${your_org}" --menu "$3" 0 0 0)
  options=(${MENU_OPTIONS})
  choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  echo $choice
}

function get_option() {
  echo "${!1}" | sed -n "$2p" | sed -e 's/^ *//g' -e 's/ *$//g'
}

function get_input() {
  cmd=(dialog --title "$1" --backtitle "${your_org}" --inputbox "$2" 8 50)
  result=$("${cmd[@]}" 2>&1 >/dev/tty)
  echo $result
}

function confirm() {
  cmd=(dialog --title "$1"  --yesno "$2" 10 80)
  result=$("${cmd[@]}" 2>&1 >/dev/tty)
  echo $?
}

display_gauge 20
zone_tmp=$(knife cs zone list --noheader --fields "name" | grep -v '^#' )

# check zone here and exit if no zone info

display_gauge 40
service_tmp=$(knife cs service list --noheader --fields "name" | grep -v '^#' )

environment_tmp=$(knife environment list | grep -v '^#' | grep -v '_default')

os_tmp="windows
centos
ubuntu
gentoo"


cosmic_node_name=$(get_input "cosmic Node Name" "Enter your node name here")
if [ "${cosmic_node_name}" == "" ]; then clear; exit 1; fi

cosmic_os=$(choose_option "os_tmp" "cosmic OS" "Please choose your os")
if [ "${cosmic_os}" == "" ]; then clear; exit 1; fi
cosmic_os_name=$(get_option "os_tmp" $cosmic_os)

cosmic_zone=$(choose_option "zone_tmp" "cosmic Zones" "Please choose your zone")
echo "returns: $cosmic_zone"
if [ "${cosmic_zone}" == "" ]; then clear; exit 1; fi
cosmic_zone_name=$(get_option "zone_tmp" $cosmic_zone)

display_gauge 60
template_tmp=$(knife cs template list --noheader --fields "name" --filter "zonename:/${cosmic_zone_name}/i,ostypename:/${cosmic_os_name}/i" | grep -v '^#' )

display_gauge 80
network_tmp=$(knife cs network list --noheader --fields "name" --filter "zonename:/${cosmic_zone_name}/i" | grep -v '^#' )

cosmic_service=$(choose_option "service_tmp" "cosmic Services" "Please choose an service")
if [ "${cosmic_service}" == "" ]; then clear; exit 1; fi
cosmic_service_name=$(get_option "service_tmp" $cosmic_service)

cosmic_template=$(choose_option "template_tmp" "cosmic Templates" "Please choose an template")
if [ "${cosmic_template}" == "" ]; then clear; exit 1; fi
cosmic_template_name=$(get_option "template_tmp" $cosmic_template)

cosmic_network=$(choose_option "network_tmp" "cosmic Networks" "Please choose an network")
if [ "${cosmic_network}" == "" ]; then clear; exit 1; fi
cosmic_network_name=$(get_option "network_tmp" $cosmic_network)

for environment in $environment_tmp
do
  if [ "${cosmic_node_name:0:4}" == "$environment" ]
  then
    cosmic_environment_name=${cosmic_node_name:0:4}
  fi
done

if [ -z $cosmic_environment_name ]; then
  cosmic_environment=$(choose_option "environment_tmp" "cosmic Environment" "Please choose an environment")
  if [ "${cosmic_environment}" == "" ]; then clear; exit 1; fi
  cosmic_environment_name=$(get_option "environment_tmp" $cosmic_environment)
fi

cosmic_confirm=$(confirm "Is this information correct?" "Node name   : $cosmic_node_name \nZone        : $cosmic_zone_name \nService     : $cosmic_service_name \nTemplate    : $cosmic_template_name\nNetwork     : $cosmic_network_name\nEnvironment : $cosmic_environment_name")
if [ ! "${cosmic_confirm}" == "0" ]; then clear; exit 1; fi



##### Execute command ####

if [ "$cosmic_os_name" == "windows" ]
then
  echo Launching Windows instance and using WINRM to bootstrap.
  knife cs server create $cosmic_node_name --node-name "$cosmic_node_name" --template "$cosmic_template_name" --service "$cosmic_service_name" --zone "$cosmic_zone_name" --network "$cosmic_network_name" --bootstrap-protocol winrm --cosmic-password --environment $cosmic_environment_name

else
  echo Launching Linux instance and using SSH to bootstrap.
  knife cs server create $cosmic_node_name --node-name "$cosmic_node_name" --template "$cosmic_template_name" --service "$cosmic_service_name" --zone "$cosmic_zone_name" --network "$cosmic_network_name"  --bootstrap-protocol ssh --cosmic-password --environment "$cosmic_environment_name"
fi

