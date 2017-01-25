# Case 7140 - Purging volumes from one account can cause CreateVolume to fail on another account

MVIP=192.168.0.0
ACCOUNT1=testaccountA
ACCOUNT2=testaccountB
NOTIFY=me@solidfire.com
VOLUME_COUNT=100

echo " ========================= Setting up the test ========================="

# Create the accounts
#echo " >>> Creating the accounts for the test <<<"
python create_account.py --mvip=$MVIP --account_name=$ACCOUNT1 || { echo ">> Aborting script <<"; python send_email.py --email_to $NOTIFY --email_subject "Failed creating account"; exit 1; }
python create_account.py --mvip=$MVIP --account_name=$ACCOUNT2 || { echo ">> Aborting script <<"; python send_email.py --email_to $NOTIFY --email_subject "Failed creating account"; exit 1; }

# Create some volumes for the first account
echo " >>> Creating the volumes for the first account <<<"
python create_volumes.py --mvip=$MVIP --account_name=$ACCOUNT1 --volume_size=1 --volume_count=$VOLUME_COUNT || { echo ">> Aborting script <<"; python send_email.py --email_to $NOTIFY --email_subject "Failed creating volumes"; exit 1; }

echo " ========================= Starting the test ========================="

# Start deleting/purging the volumes from the first account
echo " >>> Deleting/purging volumes from the first account <<<"
python delete_volumes.py --mvip=$MVIP --source_account=$ACCOUNT1 --debug &

# Start creating volumes on the second account
echo " >>> Creating volumes on the second account <<<"
python create_volumes.py --mvip=$MVIP --account_name=$ACCOUNT2 --volume_size=1 --volume_count=$VOLUME_COUNT --debug || {
        echo
        echo
        echo
        echo
        echo "============================================================================"
        echo ">>               It looks like we just recreated case 7140                <<"
        echo "============================================================================"
        echo
        echo
        echo
        echo
        echo
        python send_email.py --email_to $NOTIFY --email_subject "Possible case 7140 recreate"
        kill $!
        exit 1
}
