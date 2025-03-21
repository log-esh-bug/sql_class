#!/bin/bash
source setup.sh

if [ -n "$1" ];then
    BACKUP_FREQUENCY=$1
fi

backup_helper(){
    # pgbackrest --stanza=class backup > /dev/null

    ssh ${S_USERNAME}@${S_REMOTE_HOST_NAME} "bash ${BACKUP_SCRIPT}" > /dev/null

    if [ $? -ne 0 ]
    then
        $LOG_SCRIPT "Backup failed.Safely Exiting..."
        # rm backup.pid
        exit 1
    fi
    $LOG_SCRIPT "Backup Initiated Successfully( Every ${BACKUP_FREQUENCY} )."
}

backup_helper
