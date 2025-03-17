#!/bin/bash
source setup.sh

remove_record_by_name(){

    read -p "Enter the name: " name
    # name='logesh'

    matches=$(psql ${PGDATABASE} -tc "SELECT * FROM ${INFO_TABLE} WHERE name='${name}'")
    if [ -z "$matches" ]; then
        echo "Match not found!"
        return
    fi
    ct=$(echo "$matches"|wc -l)

    if ((ct == 1)); then
        echo "Record to be deleted:"
        echo $matches
        read -p "Do you want to continue?[y/n]:" ch
        case $ch in
            y|Y)
                local temp_id=$(echo $matches | cut -d '|' -f 1)
                psql ${PGDATABASE} -qtc "DELETE FROM ${INFO_TABLE} WHERE id=${temp_id}"
                ;;
            n|N)
                echo "Record not deleted"
                ;;        
        esac
        return
    fi

    read -p "Multiple matches found with $name! Do you want to delete all? [y/n] " ch

    if [[ $ch == y ]]; then
        psql ${PGDATABASE} -qtc "DELETE FROM ${INFO_TABLE} WHERE name='${name}'"
        echo "All records with $name have been deleted."
        return
    fi
}

remove_record_by_id(){
    read -p "Enter the id of the student record to be deleted : " temp_id

    matches=$(psql ${PGDATABASE} -tc "SELECT * FROM ${INFO_TABLE} WHERE id=${temp_id}")
    if [ -z "$matches" ]; then
        echo "Match not found!"
        return
    fi

    echo "Record to be deleted:"
    echo "$matches" | sed "s/|*//g"
    read -p "Do you want to continue?[y/n]:" ch
    case $ch in
        y|Y)
            psql ${PGDATABASE} -qtc "DELETE FROM ${INFO_TABLE} WHERE id=${temp_id}"
            ;;
        n|N)
            echo "Record not deleted"
            ;;        
    esac
}