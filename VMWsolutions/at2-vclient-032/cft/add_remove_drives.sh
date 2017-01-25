#!/bin/bash

nodeips="192.168.133.00,192.168.133.00,192.168.133.00"
mvip=192.168.000.0
username=script_user
password=solidfire
notify="your.name@solidfire.com"
toolong=30 #minutes

# This is currently set up to do 3 drives at once, but can easily be modified to do anywhere from 1 - 9

while true; do
    for node in ${nodeips//,/ }; do
        echo ">> Remove/add drives 1-3 on $node <<"
        remove_drives.py --mvip=$mvip --user=$username --pass=$password --email_notify=$notify --node_ips=$node --wait_threshold=$toolong --drive_slots=1,2,3 || { echo ">> Aborting script <<"; send_email.py --email_to $notify --email_subject "Failed removing drives"; exit 1; }
        add_drives.py --mvip=$mvip --user=$username --pass=$password --email_notify=$notify --node_ips=$node --by_node --wait_threshold=$toolong --drive_slots=1,2,3 || { echo ">> Aborting script <<"; send_email.py --email_to $notify --email_subject "Failed adding drives"; exit 1; }

        echo ">> Waiting a little while <<"
        sleep 180

        echo ">> Remove/add drives 4-6 on $node <<"
        remove_drives.py --mvip=$mvip --user=$username --pass=$password --email_notify=$notify --node_ips=$node --wait_threshold=$toolong --drive_slots=4,5,6 || { echo ">> Aborting script <<"; send_email.py --email_to $notify --email_subject "Failed removing drives"; exit 1; }
        add_drives.py --mvip=$mvip --user=$username --pass=$password --email_notify=$notify --node_ips=$node --by_node --wait_threshold=$toolong --drive_slots=4,5,6 || { echo ">> Aborting script <<"; send_email.py --email_to $notify --email_subject "Failed adding drives"; exit 1; }

        echo ">> Waiting a little while <<"
        sleep 180

        echo ">> Remove/add drives 7-9 on $node <<"
        remove_drives.py --mvip=$mvip --user=$username --pass=$password --email_notify=$notify --node_ips=$node --wait_threshold=$toolong --drive_slots=7,8,9 || { echo ">> Aborting script <<"; send_email.py --email_to $notify --email_subject "Failed removing drives"; exit 1; }
        add_drives.py --mvip=$mvip --user=$username --pass=$password --email_notify=$notify --node_ips=$node --by_node --wait_threshold=$toolong --drive_slots=7,8,9 || { echo ">> Aborting script <<"; send_email.py --email_to $notify --email_subject "Failed adding drives"; exit 1; }

        echo ">> Waiting a little while <<"
        sleep 180
    done
done
