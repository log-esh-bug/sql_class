#!/bin/bash

source pgproperties.sh

psql --dbname=${PGDATABASE} --command="CREATE OR REPLACE FUNCTION get_random_marks() 
        RETURNS INTEGER AS \$\$
        BEGIN
            RETURN 100*(0.7 + random()*0.3);
        END;
        \$\$ LANGUAGE plpgsql;"

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