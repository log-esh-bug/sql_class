#!/bin/bash 

#######################################################


source setup.sh

#######################################################

cleanup(){
	# echo "Cleanup called"
	drop_lock startexam.pid	
	drop_lock findtopper.pid
	drop_lock startbackup.pid
}
trap cleanup EXIT

display_help(){
	cat <<- _eof_
		Usage: $0 [Option]
			-i (or) --interactive	Interactive mode
			-a (or) --add		Add Record to Database[$INFO_DB]
			-r (or) --remove	To remove student From Database[$INFO_DB]
			-f (or) --find-record	To Find student From Database[$INFO_DB]
			-p (or) --printdb	Print the Database
			-d (or) --destroy	To Destroy the Database[$INFO_DB]
			-h (or) --help		Display help
			-stex (or) --start-exam	Start Exam
			-spex (or) --stop-exam	Stop Exam
			-sttop (or) --start-topper	Start Topper Finding
			-sptop (or) --stop-topper	Stop Topper Finding
			-stbp (or) --start-backup	Start Backup
			-spbp (or) --stop-backup	Stop Backup
	_eof_
}

display_help_interactive(){
	cat <<- _eof_
		Help------------------------------------
		a 	Add Record to Database[$INFO_DB]
		r	To remove student From Database[$INFO_DB]
		f	To Find student From Database[$INFO_DB]
		p 	Print the Database
		d 	To Destroy the Database[$INFO_DB]
		h 	Display help
		q	To quit the program
		stex	Start Exam
		spex	Stop Exam
		sttop	Start Topper Finding
		sptop	Stop Topper Finding
		stbp	Start Backup
		spbp	Stop Backup
		----------------------------------------
	_eof_
}

add_record(){
	read -p "Enter the name     : " name
	read -p "Enter the age      : " age
	read -p "Enter the contact  : " contact

	psql --dbname=${PGDATABASE} --quiet --command="INSERT INTO ${INFO_TABLE} (name,age,contact) VALUES('${name}',${age},'${contact}')"
	echo "Record (${name}, ${age}, ${contact})added successfully."
}

remove_record(){

    read -p "Enter the name: " name

    matches=$(psql --dbname=${PGDATABASE} --tuples-only --command="SELECT * FROM ${INFO_TABLE} WHERE name='${name}'")
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
                psql --dbname=${PGDATABASE} --quiet --tuples-only --command="DELETE FROM ${INFO_TABLE} WHERE id=${temp_id}"
                ;;
            n|N)
                echo "Record not deleted"
                ;;        
        esac
        return
    fi

    read -p "Multiple matches found with $name! Do you want to delete all? [y/n] " ch

    if [[ $ch == y ]]; then
        psql --dbname=${PGDATABASE} --quiet --tuples-only --command="DELETE FROM ${INFO_TABLE} WHERE name='${name}'"
        echo "All records with $name have been deleted."
        return
    fi

	remove_record_by_id
}

remove_record_by_id(){
    read -p "Enter the id of the student record to be deleted : " temp_id

    matches=$(psql --dbname=${PGDATABASE} --tuples-only --command="SELECT * FROM ${INFO_TABLE} WHERE id=${temp_id}")
    if [ -z "$matches" ]; then
        echo "Match not found!"
        return
    fi

    echo "Record to be deleted:"
    echo "$matches" | sed "s/|*//g"
    read -p "Do you want to continue?[y/n]:" ch
    case $ch in
        y|Y)
            psql --dbname=${PGDATABASE} --quiet --tuples-only --commands="DELETE FROM ${INFO_TABLE} WHERE id=${temp_id}"
            ;;
        n|N)
            echo "Record not deleted"
            ;;        
    esac
}


find_record(){
	read -p "Find by Name/Id[n/i] : " choice
	case $choice in
		n|name)
			read -p "Enter the name: " name
			psql --dbname=${PGDATABASE} --no-align --field-separator=$'\t' --command="SELECT * FROM ${INFO_TABLE} WHERE name='${name}'"
			;;
		i|id)
			read -p "Enter the id: " id
			psql --dbname=${PGDATABASE} --no-align --field-separator=$'\t' --command="SELECT * FROM ${INFO_TABLE} WHERE id='${id}'"
			;;
		*)
			echo "Invalid choice!"
			;;
	esac
}

empty_database(){
	read -p "Are you sure want to destroy the database![y/n/q]:" choice
	case $choice in
		y | Y)
			psql --dbname=${PGDATABASE} --quiet --command="TRUNCATE TABLE ${INFO_TABLE} CASCADE"
			echo "Database Destroyed!"
			;;
		q | Q)
			echo "Program Terminated successfully!"
			exit
			;;
		*)
			;;
	esac
}

print_db(){
	read -p "Enter the database to print [Info(i)/Scores(s)/Toppers(t)](space separated choices):" choice
	for i in $choice
	do
		case $i in
			Info | i)
				psql --dbname=${PGDATABASE} --pset pager=off --command="SELECT * FROM $INFO_TABLE"
				;;
			Scores | s)
				psql --dbname=${PGDATABASE} --pset pager=off --command="SELECT * FROM $MARKS_TABLE"
				;;
			Toppers | t)
				psql --dbname=${PGDATABASE} --pset pager=off --command="SELECT * FROM $TOPPERS_TABLE"
				;;
			*)
				echo "Invalid choice!"
				;;
		esac
	done
}

#usage: start_backend_helper backend_name args
start_backend_helper(){
	fetch_lock ${1}.pid

	local pid_file=${PARENT_DIR}/${1}.pid
	if [ -e ${pid_file} ];then
		local pid=$(cat ${pid_file})
	    if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			echo "${1} already started!"
			drop_lock ${1}.pid
			return
		fi
	fi
	echo "${1} Started and will happen for every $2!"
	${PARENT_DIR}/${1}.sh ${2}&
	echo "$!" > ${pid_file}
	drop_lock ${1}.pid
}

#usage: stop_backend_helper backend_name
stop_backend_helper(){
	fetch_lock ${1}.pid

	local pid_file=${PARENT_DIR}/${1}.pid
	if [ -e ${pid_file} ];then
		local pid=$(cat ${pid_file}) 
		if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			kill -9 $pid
			rm ${pid_file}
			echo "${1} Stopped!"
			drop_lock ${1}.pid
			return
		else
			rm ${pid_file}
			echo "${1}.pid file contains corrupted pid!"
		fi
	fi
	drop_lock ${1}.pid
	echo "${1} not started already. First start one!"
}

start_exam_helper(){
	start_backend_helper startexam $EXAM_FREQUENCY
}

stop_exam_helper(){
	stop_backend_helper startexam
}

start_finding_topper_helper(){
	start_backend_helper findtopper $TOPPER_FINDING_FREQUENCY
}

stop_finding_topper_helper(){
	stop_backend_helper findtopper
}

start_backup_helper(){
	ssh ${S_USERNAME}@${S_REMOTE_HOST_NAME} "$S_REMOTE_BACKUP_SERVER_SCRIPT start_bp"&
}

stop_backup_helper(){
	ssh ${S_USERNAME}@${S_REMOTE_HOST_NAME} "$S_REMOTE_BACKUP_SERVER_SCRIPT stop_bp"
}

interactive_mode(){
	local choice=
	display_help_interactive
	read -p "Enter the choice	: " choice
	while [ true ];
	do
		case $choice in
			r)
				remove_record
				;;
			d)
				empty_database
				;;
			h)
				display_help_interactive
				;;		
			p)
				print_db
				;;
			a)
				add_record
				;;
			f)
				find_record
				;;
			stex)
				start_exam_helper 
				;;
			spex)
				stop_exam_helper
				;;
			sttop)
				start_finding_topper_helper
				;;
			sptop)
				stop_finding_topper_helper
				;;
			stbp)
				start_backup_helper
				;;
			spbp)
				stop_backup_helper
				;;
			q)
				exit 0
				;;
			*)
				echo "$0: inavlid option -- '$choice'"
				display_help_interactive
				;;
		esac
		read -p "Enter the choice	: " choice
	done
}
############################################################################################################
# Main Script
############################################################################################################

#Initializing database id if there is nothing!
if [ ! -e $INFO_DB ];then 
	id=1000
fi

if [ $# -eq 0 ];then
	display_help
fi

if [ ! -d $LOCK_DIR ];then
	mkdir $LOCK_DIR
fi

if [ ! -d $DATA_DIR ];then
	mkdir $DATA_DIR
fi

if [ ! -e $LOG_SCRIPT ];then
	echo "Log script not found!"
	exit 1
fi


while [ $1 ];
do
	#echo "$1"
	case $1 in
		-i | --interactive)
			interactive_mode
			;;
		-r | --remove)
			remove_record
			;;
		-d | --destroy)
			empty_database
			;;
		-h | --help)
			display_help
			;;		
		-p | --printdb)
			print_db
			;;
		-a | --add)
			add_record
			;;
		-stex | --start-exam)
			start_exam_helper
			;;
		-spex | --stop-exam)
			stop_exam_helper
			;;
		-sttop | --start-topper)
			start_finding_topper_helper
			;;
		-sptop | --stop-topper)
			stop_finding_topper_helper
			;;
		-f | --find-record)
			find_record
			;;
		-stbp | --start-backup)
			start_backup_helper
			;;
		-spbp | --stop-backup)
			stop_backup_helper
			;;
		*)
			echo "$0: inavlid option -- '$1'"
			display_help
			;;
	esac
	shift
done
