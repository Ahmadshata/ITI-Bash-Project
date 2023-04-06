#!/bin/bash


# validation regex

regex="^[a-zA-Z]+$"	

# creating the DBMS directory which contains our databases

mkdir DBMS 2> /dev/null

# changing select prompt 

PS3="Choose a number: "

function validate {


	if [[ $1 =~ ^[a-zA-Z]+$ ]]
	then 
		return 0
	else
		return 1
	fi	
}

function subsidiary {

echo "==================================================="
echo "                  Connection menu		         "
echo "==================================================="

select y in "Create table" "List tables" "Drop table" "Insert into table" "Select from table" "Update table" " Delete table" "return to main menu"
                                do
                                        case $REPLY in
                                                1) create_table $1 ;;
                                                2) . ./list_tables.sh ;;
                                                3) . ./drop_table.sh ;;
                                                4) insert $1 ;;
                                                5) . ./select_from.sh ;;
                                                6) . ./update.sh ;;
                                                7) . ./delete.sh ;;
                                                8) main ;;
                                                *) echo "Invaild input" ;;

                                        esac
                                done
			}

prepare_table()
{
    read -p "Enter number of columns :" columns_number
    type_arr=()
    key=""
    col_num=1

    while [[ $columns_number -gt 0 ]]
    do
        read -p "Enter column $col_num name: " column_name 
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

                column_arr+=("$column_name")

		echo "Select column datatype"
		select dtype in "INTEGER" "VARCHAR"
		    do
			case $REPLY in
			   1)type_arr+=("$dtype")
				   break;;
			   2)type_arr+=("$dtype")
				   break;;
			   *) echo "Invalid datatype"
		         esac
		    done

                        if [[ $key == "" ]]
                        then
                            echo "Make it a Primary Key?"
                            select choice in yes no
                            do
                                case $choice in 
                                "yes")
                                    key=$col_num 
                                    break;;
                                "no")
                                    break;;
                                esac

                            done
                        fi
                        echo
                        columns_number=$(($columns_number-1))
            else
                echo "Column already exists"
		increment=1
            fi
            check=0
                              
        else
            echo "Invalid input, please enter a valid column name"    
        fi

	if [[ $increment != 1 && $column_name != "" ]]
	then
	((col_num++))
	 increment=0
 	else
	 increment=0
	fi

    done

    if [[ $key == "" ]]
    then
	    key=1
	    echo "Table must have a primary key"
	    echo "Column $key is set as your primary key"
    fi

      touch "$db_path"/"$table_name"
      echo -e "Table $table_name created successfully \n"


    {
        printf ":%s" "${column_arr[@]}"
        echo -ne "\n"
        printf ":%s" "${type_arr[@]}" 
        echo -ne "\n"
        echo "$key"

    } >> "$1"

    sed -i 's/://' "$1"
    column_arr=() 
      subsidiary ./DBMS/$name
}


create_table()
{
    db_path="$1"
    read -p "Enter table name: " table_name
    if [[ $table_name =~ $regex ]]
    then
        if [[ -f "$db_path"/"$table_name" ]]
        then
            echo "Table already exsists"
	    subsidiary ./DBMS/$name
	    echo "Returning to connection menu"
        else
            prepare_table "$db_path"/"$table_name"
        fi
    else
        echo "Invalid table name"
	    echo "Returning to connection menu"
	    subsidiary ./DBMS/$name
    fi
    
}

function insert {

db_path="$1"

read -p "Enter table name: " name
if [[ $name =~ $regex ]]
then
        if [[ -f "$db_path"/"$name" ]]
        then

              table_key=`awk -F":" '{if(NR==3) print $1}'  $db_path/$name`
              num_col=`awk 'END{print NF}' $db_path/$name`
                for (( i=1; i<=num_col; i++ ))
                        do
                                col_name=`awk -v i=$i -F":" '{if(NR==1) print $i}' $db_path/$name`
                                col_type=`awk -v i=$i -F":" '{if(NR==2) print $i}' $db_path/$name`
                                read -p "Enter the value of $col_name ($col_type): " data
                                if [[ $col_type == "INTEGER" ]]
                                then
                                        if [[ $data =~ ^[0-9]+$ ]]
                                        then
                                                col_${i}=$data
                                                echo ${col_${i}}
                                        else
                                                echo "You must enter an integer number"
                                        fi
                                else
                                         if [[ $data =~ ^[a-zA-Z]+$  ]]
                                         then
                                                col_[$i]=$data
                                                echo ${col_[i]}
                                         else
                                                echo "You must enter a string"

                                        fi
                                fi
                        done
        else
                echo "Table does not exist"
                subsidiary ./DBMS/$name
        fi
else
        echo "Invalid table name"
            echo "Returning to connection menu"
            subsidiary ./DBMS/$name
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
				subsidiary ./DBMS/$name
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
