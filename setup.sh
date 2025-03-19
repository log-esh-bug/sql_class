#!/bin/bash

source pgproperties.sh

REQUIRED_ROUTINES="get_random_marks marks_updater topper_finder"

is_table_exists(){
    a=$(psql $PGDATABASE -qtc "SELECT COUNT(*) FROM pg_tables WHERE tablename='$1';")
    if ((a==1));then
        return 0
    else
        return 1
    fi
}

pg_isready -q
ret=${?}


if ((ret!=0));then
    $LOG_SCRIPT "Postgres server is not running"
    echo "Postgres server is not running. Quiting....."
    exit 1
fi

if ( ! (psql -lqt | cut -d '|' -f 1 | grep -cq ${PGDATABASE}) );then
    $LOG_SCRIPT "Could not able to connect to ${PGDATABASE} database"
    echo "Could not able to connect to '${PGDATABASE}' database. Quiting...."
    exit 1
fi

if ! is_table_exists ${INFO_TABLE};then
    psql --dbname=${PGDATABASE} --quiet --tuples-only --command="CREATE TABLE ${INFO_TABLE}(
                                                                    id SERIAL PRIMARY KEY,
                                                                    name VARCHAR(50),
                                                                    age INTEGER,
                                                                    contact VARCHAR(50));"
    echo "${INFO_TABLE} not exits.Created one!"
fi

if ! is_table_exists ${MARKS_TABLE};then
    psql --dbname=${PGDATABASE} --quiet --tuples-only --command="CREATE TABLE ${MARKS_TABLE}(
                                                                    id INTEGER REFERENCES ${INFO_TABLE}(id) ON DELETE CASCADE,
                                                                    sub1 INTEGER,
                                                                    sub2 INTEGER,
                                                                    sub3 INTEGER,
                                                                    sub4 INTEGER,
                                                                    total INTEGER
                                                                    );"
    echo "${MARKS_TABLE} not exits.Created one!"
fi

if ! is_table_exists ${TOPPERS_TABLE};then
    psql --dbname=${PGDATABASE} --quiet --tuples-only --command="CREATE TABLE ${TOPPERS_TABLE}(
                                id INTEGER REFERENCES ${INFO_TABLE}(id) ON DELETE CASCADE,
                                name VARCHAR(50),
                                sub1 INTEGER,
                                sub2 INTEGER,
                                sub3 INTEGER,
                                sub4 INTEGER,
                                total INTEGER
                                );"
    echo "${TOPPERS_TABLE} not exits.Created one!"
fi

functions=$(psql --dbname=${PGDATABASE} --tuples-only --command="SELECT proname AS function_name FROM pg_proc WHERE pronamespace = 'public'::regnamespace;")
   
for i in ${REQUIRED_ROUTINES};do
    if [[ ! $functions =~ $i ]];then
        echo "Routine $i not found. Creating From define_routines.sh"
        source define_routines.sh
        exit
    fi
done