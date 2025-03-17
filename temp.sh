#!/bin/bash

source setup.sh
TOPPER_FINDING_FREQUENCY=5

if [ -n $1 ];then
    TOPPER_FINDING_FREQUENCY=$1
    $LOG_SCRIPT "Topper Finding Frequency set to $1"
fi

find_topper_helper(){
    psql --dbname=${PGDATABASE} --quiet --tuples-only --command="SELECT topper_finder()" > /dev/null
}

while true
do
    find_topper_helper
    sleep $TOPPER_FINDING_FREQUENCY
done

