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

select_from()
{
	read -p "Enter table name: " st_name
	if [[ -f $1/$st_name ]]
	then
		select choice in "All" "Column" "Row" 
		do
			case $choice in 
				"Column")
					read -p "Enter column number that you want to display: " scol_num
					cols_num=$(awk -F ":" 'END{print NF}' $1/$st_name)
					rows_num=$(awk -F ":" 'END{print NF}' $1/$st_name)
					if [[ $scol_num =~ ^[0-9]+$ ]]
					then
						if [[ $scol_num -gt $cols_num ]]
						then
							echo "Out of range"
						else
							awk -F ":" -v cn=$scol_num  '{if(NR>3) print $cn}' $1/$st_name
						fi
					else
						echo "Please enter a valid number"
					fi
					subsidiary $1
					break;;
				"Row")
					read -p "Enter row number that you want to display: " srow_num
					cols_num=$(awk 'END{print NF}' $1/$st_name)
					rows_num=$(awk 'END{print NF}' $1/$st_name)
					if [[ $srow_num =~ ^[0-9]+$ ]]
					then
						if [[ $srow_num -gt $rows_num ]]
						then
							echo "Out of range"
						else
							awk -F ":" -v rn=$(($srow_num+3)) '{if(NR==rn) print $0}' $1/$st_name
						fi
					else
						echo "Please enter a valid number"
					fi
					subsidiary $1
					break;;
				"All")
					awk -F ":" '{if(NR>3) print $0}' $1/$st_name
					subsidiary $1
					break;;
			esac

		done




					

	else
		echo "Table doesn't exist"
	fi
	echo
}
update_table()
{
	read -p "Enter table name: " t_name
	if [[ -f $1/$t_name ]]
	then
		
		select choice in "Line number" "Primary key"
		do
			case $choice in 
				"Line number")
					read -p "Enter row number to change" row_num
                    row_num=$(("$row_num"+3))
					last_line=$(awk -F ":" 'END{print NR}' $1/$t_name)
					if [[ $row_num -gt $last_line ]]
					then
						echo "Out of range"
					else
						colnum=$(awk -F ":" '{if(NR==1) print NF}' $1/$t_name)
                        i=1
						#echo outside loop
						while [[ $i -le $colnum ]]
						do
							#echo inside loop
							col_arr=$(awk -v i=$i -F":" '{if(NR==1) print $i}' $1/$t_name)
							col_type=$(awk -v i=$i -F":" '{if(NR==2) print $i}' $1/$t_name)
							current_value=$(awk -v i=$i -v ln=$row_num -F":" '{if(NR==ln) print $i}' $1/$t_name)
							read -p "Enter the new value for $col_arr ($col_type) ($current_value): " new_value
							if [[ $col_type == "INTEGER" && $new_value =~ ^[0-9]+$  ]]
							then
								sed -i "$row_num s/$current_value/$new_value/" $1/$t_name
							elif [[ $col_type == "VARCHAR" && $new_value =~ ^[a-zA-Z]+$  ]]
							then
								sed -i "$row_num s/$current_value/$new_value/" $1/$t_name
							else
								echo "Invalid type"
								break
							fi
							i=$(($i+1))
						done
					fi
					#clear
					echo "Returning to connection menu"
					subsidiary $1 
                    break;;

				"Primary key")
					read -p "Enter the primary key: " pk_value
					last_line=$(awk -F ":" 'END{print NR}' $1/$t_name)
					pk_col_num=$(awk -F":" '{if(NR==3) print $1}'  $1/$t_name)
					#echo $pk_col_num
					#pk_arr+=$(awk -F ":" -v pk=$pk_col_num '{print $pk}' $1/$t_name)
					pk_arr=()
					index=0
					line_n=0
					#awk -v pk_col_num=$pk_col_num '{print i,pk_col_num}'
					for (( i=4; i<= $last_line; i++ ))
					do
						
						pk_arr[$index]=$(awk -F ":" -v i=$i -v pk_col_num=$pk_col_num  '{if(NR==i) print $pk_col_num}' $1/$t_name)
						echo "${pk_arr[$index]}"
						
						if [[ $pk_value == "${pk_arr[$index]}" ]]
						then
							echo inside check
							line_n=$i
							break

						fi
						index=$(($index+1))
					done

					if [[ $line_n != 0 ]]
					then
						col_num=$(awk -F ":" 'END{print NF}' $1/$t_name)
						i=1
						while [[ $i -le $col_num ]]
						do
							col_arr=$(awk -v i=$i -F":" '{if(NR==1) print $i}' $1/$t_name)
							col_type=$(awk -v i=$i -F":" '{if(NR==2) print $i}' $1/$t_name)
							current_value=$(awk -v i=$i -v ln=$line_n -F":" '{if(NR==ln) print $i}' $1/$t_name)
							read -p "Enter the new value for $col_arr ($col_type) ($current_value): " new_value
							if [[ $col_type == "INTEGER" && $new_value =~ ^[0-9]+$  ]]
							then
								sed -i "$line_n s/$current_value/$new_value/" $1/$t_name
								
							elif [[ $col_type == "VARCHAR" && $new_value =~ ^[a-zA-Z]+$  ]]
							then
								sed -i "$row_num s/$current_value/$new_value/" $1/$t_name
							else
								echo "Invalid type"
								break
							fi
							i=$(($i+1))
						done
							
					else
						echo "Value doesn't exist"
					fi
					break;;

				esac

		done

	else
		echo "Table doesn't exist"
	fi

		

}

function subsidiary {

echo "==================================================="
echo "                  Connection menu		         "
echo "==================================================="

select y in "Create table" "List tables" "Drop table" "Insert into table" "Select from table" "Update table" " Delete table" "return to main menu"
                                do
                                        case $REPLY in
                                                1) 
													create_table $1 ;;
                                                2) 
													ls $1 | cat ;;
                                                3) 
													drop_table.sh ;;
                                                4) 
													insert $1 ;;
                                                5) 
													select_from $1 ;;
                                                6) 
                                                    update_table $1 ;;
                                                7) 
													delete $1 ;;
                                                8) 
													main ;;
                                                *) 
													echo "Invaild input" ;;

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
      subsidiary "$db_path"
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
	    subsidiary "$db_path"
	    echo "Returning to connection menu"
        else
            prepare_table "$db_path"/"$table_name"
        fi
    else
        echo "Invalid table name"
	    echo "Returning to connection menu"
	    subsidiary "$db_path"
    fi
    
}
function delete {

db_path="$1"

read -p "Enter table name: " d_name
if [[ $d_name =~ $regex ]]
then
        if [[ -f "$db_path"/"$d_name" ]]
        then
              rows_num=`awk -F":" 'END{print NR}' "$db_path"/"$d_name"`
		select del in "Delete by row" "Delete all"
		do
			case $REPLY in 
			  1) read -p "Enter the number of the row you want to delete: " row
				if [[ $row =~ ^[0-9]+$ ]]
				then
				  var=$((row+3)) 
                                 if [[ $var -le $rows_num ]]
				 then
					 sed -i "${var}d" "$db_path"/"$d_name"
					 break
				 else
					 echo "Row does not exist!"
				 fi
			  	else
					echo "invalid input"
				fi
				  ;;
			  2)select choice in "yes" "no"
			  do
				  case $REPLY in 
					  1) sed -i '4,$d' "$db_path"
						 break ;;

					  2) echo "Returning back to connection menu"
                                             subsidiary "$db_path"
					     ;;

				          *) echo "Invalid input"
						  ;;
				  esac
			  done 
				  ;;

			  *) echo "Invalid input"
				  ;;
			esac
		done
        else
                echo "Table does not exist"
                echo "Returning back to connection menu"
                subsidiary "$db_path"	
        fi
else
        echo "Invalid table name"
            echo "Returning to connection menu"
            subsidiary "$db_path" 
fi

echo "Values inserted successfully"

}

function insert {

db_path="$1"

read -p "Enter table name: " i_name
if [[ $i_name =~ $regex ]]
then
        if [[ -f "$db_path"/"$i_name" ]]
        then

              table_key=$(awk -F":" '{if(NR==3) print $1}'  $db_path/$i_name)
	      num_col=$(awk -F":" '{if (NR==1) print NF}' $db_path/$i_name)
                for (( i=1; i<=num_col; i++ ))
                        do
                                col_name=$(awk -v i=$i -F":" '{if(NR==1) print $i}' $db_path/$i_name)
                                col_type=$(awk -v i=$i -F":" '{if(NR==2) print $i}' $db_path/$i_name)
                                read -p "Enter the value of $col_name ($col_type): " data
                                if [[ $col_type == "INTEGER" ]]
                                then
                                elements+=$(awk -v i=$i -F":" '{print $i}' $db_path/$i_name)
                                if [[ $i -eq $table_key ]]
                                then
                                        for element in "${elements[@]}"
                                        do
                                            if [[ $element != "$data"  ]]
                                            then
                                                continue
                                            else
                                                check=1
                                                break
                                            fi
                                        done

                                        if [[ $check != 1 ]]
                                        then

                                        if [[ $data =~ ^[0-9]+$ ]]
                                        then
                                                col[$i]=$data
                                        else
                                                echo "You must enter an integer number"
						                        echo "Returning back to connection menu"
						                        subsidiary "$db_path" 
                                        fi
            else
              echo "Dublicated value! primary key must be unique"
	      echo "Returning back to connection menu"
          elements=()
              subsidiary "$db_path" 
            fi
else
                                        if [[ $data =~ ^[0-9]+$ ]]
                                        then
                                                col[$i]=$data
                                        elif [[ -z $data  ]]
					then
						col[$i]="NULL"
					else	
                                                echo "You must enter an integer number"
						echo "Returning back to connection menu"
                                                subsidiary "$db_path" 
                                        fi
fi
   
                                else
if [[ $i -eq $table_key ]]
then
         for element in "${elements[@]}"
           do
               if [[ $element != "$data"  ]]
              then
                 continue
              else
                check=1
                break
               fi
           done

           if [[ $check != 1 ]]
           then

                                         if [[ $data =~ ^[a-zA-Z]+$  ]]
                                         then
						 col[$i]=$data
                                         else
                                                echo "You must enter a string"
						echo "Returning back to connection menu"
                                                subsidiary "$db_path" 

                                        fi
            else
              echo "Dublicated value! primary key must be unique"
	      echo "Returning back to connection menu"
              subsidiary "$db_path"
            fi
else
                                        if [[ $data =~ ^[a-zA-Z]+$  ]]
                                         then
                                                 col[$i]=$data
					 elif [[ -z $data  ]]
                                         then
                                                col[$i]="NULL"
                                         else

                                                echo "You must enter a string"
						echo "Returning back to connection menu"
                                                subsidiary "$db_path"

                                       fi
fi

                                fi
                        done
        else
                echo "Table does not exist"
                echo "Returning back to connection menu"
                subsidiary "$db_path"
        fi
else
        echo "Invalid table name"
            echo "Returning to connection menu"
            subsidiary "$db_path" 
fi

echo "Values inserted successfully"

for i in "${col[@]}"
do
	echo -ne "$i:" >> $db_path/$i_name
done
	echo -ne "\n" >> $db_path/$i_name
	sed -i 's/:$//' $db_path/$i_name
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
