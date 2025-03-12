#!/bin/bash

source setup.sh

read -p "Enter the name     : " name
read -p "Enter the age      : " age
read -p "Enter the contact  : " contact

psql $PGDATABASE -qtc "INSERT INTO ${INFO_TABLE} VALUES(1028,'${name}',${age},'${contact}')"