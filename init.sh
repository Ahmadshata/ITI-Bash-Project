#! /bin/bash
	
mkdir DBMS 2> /dev/null
PS3="Choose a number: "

function validate {


	if [[ $1 =~ ^[a-zA-Z]+$ ]]
	then 
		return 0
	else
		return 1
	fi	
}

function main {

clear

echo "==================================================="
echo "          DBMS - Bash Script Version		 "
echo "==================================================="

select x in "Create database" "List databases" "Connect to a database" "Drop database" "Exit"
do
	case $REPLY in
		1) read -p "Enter the database name: " name

		if validate $name
		      then
	 		 	mkdir ./DBMS/$name
				echo -ne '█████                     (33%)\r'
				sleep 0.5
				echo -ne '█████████████             (66%)\r'
				sleep 0.5
				echo -ne '███████████████████████   (100%)\r'
				echo -ne " Database $name is created successfully \n"
		      else
			      echo "Syntax Error Invalid name for database!"
			      echo "Returning to main menu"
		  fi
		   ;;
		2) ls ./DBMS
		   ;;
		3) read -p "Enter the database name: " name


			if [[ -d ./DBMS/$name ]]
			then
			select y in "Create table" "List tables" "Drop table" "Insert into table" "Select from table" "Update table" " Delete table" "return to main menu"
			do
				case $REPLY in
					1) . ./create_table ;;
					2) . ./list_tables ;;
					3) . ./drop_table ;;
					4) . ./insert_into ;;
					5) . ./select_from ;;
					6) . ./update ;;
					7) . ./delete ;;
					8) main ;;
					*) echo "Invaild input" ;;
					
				esac
			done 
		else
			echo "Database does not exist"
		fi ;;

		4)read -p "Enter the database name: " name
			if [[ -d ./DBMS/$name ]]
			then
		   	echo "Are you sure you want to permanently delete $name"
		   	select z in "yes" "no"
		   	do
			   case $REPLY in
				   1) rm -rf ./DBMS/$name 
					   main
					   break;;
				   2) main ;;
				   *) echo "Invalid input" ;;
			   esac
		   	done
		else
			echo "Database does not exist"
		fi
		   ;;
		5) exit 
		   ;;
		*) echo "Invalid input"
		   echo "Returning to main menu"
	           ;;
	esac
done
	}

	main
