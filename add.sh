#!/bin/bash

source setup.sh

add_record(){
	read -p "Enter the name     : " name
	read -p "Enter the age      : " age
	read -p "Enter the contact  : " contact

	psql --dbname=${PGDATABASE} --quiet --command="INSERT INTO ${INFO_TABLE} (name,age,contact) VALUES('${name}',${age},'${contact}')"
	echo "Record (${name}, ${age}, ${contact})added successfully."
}

add_record