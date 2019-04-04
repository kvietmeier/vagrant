#!/bin/bash
# startvm <uuid|vmname> [--type gui|headless|separate]
#
# controlvm  <uuid|vmname> <pause|resume|reset|poweroff|savestate>

read -p "What do you want to do? " option
echo -en "I want to "

case $option in
   pause)
    action=pause
    echo "$action"
    ;; 
   resume)
    action=resume
    echo "$action"
    ;;
   reset)
    action=reset
    echo "$action"
    ;;
   poweroff)
    action=poweroff
    echo "$action"
    ;;
   savestate)
    action=savestate
    echo "$action"
    ;;
   start)
    action=start
    echo "$action"
    ;;




# Start VMs in servers.yml file
#for vm in $(grep name ./servers.yml | awk '{print $3}')
#  do
#    vboxmanage startvm $vm --type headless
#  done
#
#
## Start VMs in servers.yml file
#for vm in $(grep name ./servers.yml | awk '{print $3}')
#  do
#    vboxmanage startvm $vm --type headless
#  done

