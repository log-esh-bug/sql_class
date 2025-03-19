#!/bin/bash

#postgres Specifications

INFO_TABLE=info
MARKS_TABLE=marks
TOPPERS_TABLE=toppers
PGDATABASE=class
PGUSER=logesh-tt0826
PGDATA=/home/logesh-tt0826/pg/class

#Directories
PARENT_DIR=/home/logesh-tt0826/sql_class
LOCK_DIR=${PARENT_DIR}/lock

#Frequency datas
EXAM_FREQUENCY=3
TOPPER_FINDING_FREQUENCY=5
BACKUP_FREQUENCY=10

#Logging stuffs
LOG_FILE=${PARENT_DIR}/logfile
LOG_SCRIPT=${PARENT_DIR}/dolog.sh

#Backup related stuffs
BACKUP_THRESHOLD=5
S_REMOTE_BACKUP_HOME_DIR="/home/test2/backup_class"
S_REMOTE_BACKUP_DIR="${S_REMOTE_BACKUP_HOME_DIR}/backups"
S_REMOTE_BACKUP_SERVER_SCRIPT="${S_REMOTE_BACKUP_HOME_DIR}/bp_server.sh"

#Remote details
S_REMOTE_HOST_NAME="zlabs-auto3"

#Credentials S_ ->ssh
S_USERNAME=test2


#LOCK_ROUTINES
fetch_lock(){
	while [ -e ${LOCK_DIR}/$(basename $1).lock ];
	do
		sleep 1		
	done
	touch ${LOCK_DIR}/$(basename $1).lock 
}

drop_lock(){
	if [ -e ${LOCK_DIR}/$(basename $1).lock  ];then
		rm ${LOCK_DIR}/$(basename $1).lock 
	fi
}