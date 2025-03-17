#!/bin/bash

source pgproperties.sh

pg_isready -q
ret=${?}

is_table_exists(){
    a=$(psql $PGDATABASE -qtc "SELECT COUNT(*) FROM pg_tables WHERE tablename='$1';")
    if ((a==1));then
        return 0
    else
        return 1
    fi
}


if ((ret!=0));then
    $LOG_SCRIPT "Postgres server is not running"
    echo "Postgres server is not running. Quiting....."
    exit 1
fi

if ( ! (psql -lqt | cut -d '|' -f 1 | grep -cq ${PGDATABASE}) );then
    $LOG_SCRIPT "Could not able to connect to ${PGDATABASE}"
    echo "Could not able to connect to ${PGDATABASE}. Quiting...."
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

# psql ${PGDATABASE} -f routines.sql