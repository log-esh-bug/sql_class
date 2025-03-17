#!/bin/bash

source setup.sh

EXAM_FREQUENCY=5

if [ -n $1 ];then
    EXAM_FREQUENCY=$1
    $LOG_SCRIPT "Exam Frequency set to $1"
fi

update_marks(){
    psql --dbname=${PGDATABASE} --quiet --tuples-only --command="SELECT marks_updater()" > /dev/null
    $LOG_SCRIPT "Marks updated in ${MARKS_TABLE} table."
}

while true
do
    update_marks
    sleep $EXAM_FREQUENCY
done