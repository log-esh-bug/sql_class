#!/bin/bash
source setup.sh

backup_helper(){
    pgbackrest --stanza=class backup > /dev/null

    if [ $? -ne 0 ]
    then
        $LOG_SCRIPT "Backup failed.Safely Exiting..."
        exit 1
    fi
    $LOG_SCRIPT "Taken Backup."
}

while true
do
    backup_helper
    sleep $BACKUP_FREQUENCY
done