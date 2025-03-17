#!/bin/bash

source pgproperties.sh


#Function to random marks between 70 and 100
psql --dbname=${PGDATABASE} --command="CREATE OR REPLACE FUNCTION get_random_marks() 
        RETURNS INTEGER AS \$\$
        BEGIN
            RETURN 100*(0.7 + random()*0.3);
        END;
        \$\$ LANGUAGE plpgsql;"

#Function to update marks table
psql --dbname=${PGDATABASE} --command="CREATE OR REPLACE FUNCTION marks_updater() 
        RETURNS VOID AS \$\$
        DECLARE 
            i INTEGER;
            a INTEGER;
            b INTEGER;
            c INTEGER;
            d INTEGER;
        BEGIN
            TRUNCATE ${MARKS_TABLE} CASCADE;
            for i in SELECT id FROM ${INFO_TABLE}
            LOOP
                    a := get_random_marks();
                    b := get_random_marks();
                    c := get_random_marks();
                    d := get_random_marks();
                    INSERT INTO ${MARKS_TABLE} (id, sub1, sub2, sub3, sub4, total)
                    VALUES (i, a, b, c, d, (a+b+c+d));
            END LOOP;
        END;
        \$\$ LANGUAGE plpgsql;"

#Function to find toppers
psql --dbname=${PGDATABASE} --command="CREATE OR REPLACE FUNCTION topper_finder() 
        RETURNS VOID AS \$\$
        BEGIN
            TRUNCATE ${TOPPERS_TABLE} CASCADE;
            INSERT INTO ${TOPPERS_TABLE} (id, name, sub1, sub2, sub3, sub4, total)
            SELECT ${INFO_TABLE}.id, name, sub1, sub2, sub3, sub4, total
            FROM ${INFO_TABLE} JOIN ${MARKS_TABLE} ON ${INFO_TABLE}.id = ${MARKS_TABLE}.id
            ORDER BY total DESC LIMIT 3;
        END;
        \$\$ LANGUAGE plpgsql;"