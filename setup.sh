#!/bin/bash

source pgproperties.sh

pg_isready -q
ret=${?}

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


if (($(psql $PGDATABASE -qtc "SELECT COUNT(*) FROM pg_tables WHERE tablename='${INFO_TABLE}'")!=1));then
    psql $PGDATABASE -qtc "CREATE TABLE $INFO_TABLE(
                            id SERIAL PRIMARY KEY,
                            name VARCHAR(50),
                            age INTEGER,
                            contact VARCHAR(50));"
    echo "$INFO_TABLE not exits.Created one!"
    id=1000
    echo $id >> table.id
fi

if (($(psql $PGDATABASE -qtc "SELECT COUNT(*) FROM pg_tables WHERE tablename='${MARKS_TABLE}'")!=1));then
    psql $PGDATABASE -qtc "CREATE TABLE ${MARKS_TABLE}(id INT,sub1 INT,sub2 INT,sub3 INT,sub4 INT,total INT)"
    echo "$MARKS_TABLE not exits.Created one!"
fi

# if (($(psql $PGDATABASE -qtc "SELECT COUNT(*) FROM pg_tables WHERE tablename='${INFO_TABLE}'")!=1));then
#     psql $PGDATABASE -qtc "CREATE TABLE ${INFO_TABLE}(Id INT,Name VARCHAR(50),Age INT,Contact VARCHAR(100))"
#     echo "$INFO_TABLE not exits.Created one!"
# fi
