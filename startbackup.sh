#!/bin/bash

source setup.sh
sleep_time=10

if [ -n "$1" ];then
    sleep_time=$1
    echo "sleep_time set to $1"
fi

safe_exit(){
    fetch_lock startbackup.pid

    local pid_file=${PARENT_DIR}/startexam.pid
    if [ -e ${pid_file} ];then
        rm ${pid_file}
    fi
	drop_lock startbackup.pid
    exit $1
}

while [ 0 ]
do
    pgbackrest --stanza=class --log-level-console=info backup

    if [ $? -ne 0 ]
    then
        $LOG_SCRIPT "Backup failed.Safely Exiting..."
        safe_exit 1
    fi

    $LOG_SCRIPT "Taken Backup."
    sleep $sleep_time
done