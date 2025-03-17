#!/bin/bash

source setup.sh

update_marks(){
    psql ${PGDATABASE} -qtc "SELECT marks_updater()" > /dev/null
}

while true
do
    update_marks
    sleep 5
done

