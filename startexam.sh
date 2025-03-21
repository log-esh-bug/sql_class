#!/bin/bash

source setup.sh

if [ -n "$1" ];then
    EXAM_FREQUENCY=$1
    $LOG_SCRIPT "Exam Frequency set to $1"
fi

update_marks(){
    psql --dbname=${PGDATABASE} --quiet --tuples-only --command="SELECT marks_updater()" >> /dev/null 2>&1
    if [ $? -ne 0 ]; then
        $LOG_SCRIPT "Marks updation failed."
        return
    fi
    $LOG_SCRIPT "Marks updated in ${MARKS_TABLE} table."
}

while true
do
    update_marks
    sleep $EXAM_FREQUENCY
done