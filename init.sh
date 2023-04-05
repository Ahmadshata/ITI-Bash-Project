#! /bin/bash

# validation regex
regex="^[a-zA-Z]+$"	

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

prepare_table()
{
    read -p "Enter number of columns :" columns_number
    #column_arr=("")
    type_arr=()
    key=""


    while [[ $columns_number -gt 0 ]]
    do
        read -p "Enter column name: " column_name 
        if [[ $column_name =~ $regex ]]
        then
            for value in "${column_arr[@]}"
            do
                if [[ $value != "$column_name"  ]]
                then
                    continue
                else
                    check=1
                    break
                fi
            done

            if [[ $check != 1 ]]
            then

                    read -p "Enter column datatype [int-string] : " column_type
                    if [[ $column_type == "int" || $column_type == "string" ]]
                    then
                        column_arr+=("$column_name")
                        type_arr+=("$column_type")
                        if [[ $key == "" ]]
                        then
                            echo "Make it a Primary Key? "
                            select choice in yes no
                            do
                                case $choice in 
                                "yes")
                                    key=$column_name 
                                    break;;
                                "no")
                                    break;;
                                esac

                            done
                        fi
                        echo
                        columns_number=$(($columns_number-1))
                    else
                        echo "Please choose a valid type"
                    fi
            else
                echo "column already exists"
            fi
            check=0
                  
                
        else
            echo "Invalid input, please enter a valid column name"    
        fi
    done


    {
        printf ":%s" "${column_arr[@]}"
        echo -ne "\n"
        printf ":%s" "${type_arr[@]}" 
        echo -ne "\n"
        echo "$key"

    } >> "$1"

    sed -i 's/://' "$1"
}


create_table()
{
    table_path="$1"
    read -p "Enter table name (letters only): " table_name
    if [[ $table_name =~ $regex ]]
    then
        if [[ -f "$table_path"/"$table_name" ]]
        then
            echo "Table already exsists"
        else
            echo "$table_path"/"$table_name"
            touch "$table_path"/"$table_name"
            echo "Table created successfully"
            table="$table_path"/"$table_name"
            prepare_table "$table"
        fi
    else
        echo "Invalid table name"
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
        
		1) read -p "Enter the database name: " database_name
			if validate $database_name
		      	then

				if [[ -d ./DBMS/$database_name ]]
			      	then
					echo "Databas already exists"
				else
					mkdir ./DBMS/$database_name
					echo -ne '█████                     (33%)\r'
					sleep 0.5
					echo -ne '█████████████             (66%)\r'
					sleep 0.5
					echo -ne '███████████████████████   (100%)\r'
					echo -ne " Database $database_name is created successfully \n"
			      	fi
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
						1) 
							create_table ./DBMS/$name ;;
						2) . ./list_tables.sh ;;
						3) . ./drop_table.sh ;;
						4) . ./insert_into.sh ;;
						5) . ./select_from.sh ;;
						6) . ./update.sh ;;
						7) . ./delete.sh ;;
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
