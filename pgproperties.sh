#!/bin/bash

#postgres Specifications

INFO_TABLE=info
MARKS_TABLE=marks
TOPPERS_TABLE=toppers
PGDATABASE=mydb
PGUSER=logesh-tt0826
PGDATA=/home/logesh-tt0826/pg/data

#Directories
PARENT_DIR=/home/logesh-tt0826/sql_class
LOCK_DIR=${PARENT_DIR}/lock

#Frequency datas
EXAM_FREQUENCY=3
TOPPER_FINDING_FREQUENCY=5

#Logging stuffs
LOG_FILE=${PARENT_DIR}/logfile
LOG_SCRIPT=${PARENT_DIR}/dolog.sh