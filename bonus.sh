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
db=$2

CHOICE=$(
whiptail --title "Connected to $db database" --menu "choose an option" 17 100 8 \
        "1)" "Create table"   \
        "2)" "List tables"  \
        "3)" "Drop table" \
        "4)" "Insert into table" \
        "5)" "Select from table" \
        "6)" "Update table" \
        "7)" "Delete table" \
        "8)" "Return to main menu" 3>&2 2>&1 1>&3       
)


if [ -z "$CHOICE" ]; then
        whiptail --msgbox "No option was selected" 10 100
else
         case "$CHOICE" in
               "1)")   clear
		       create_table $1 ;;
	       "2)") whiptail --msgbox "$(ls $1 | cat)" 10 100
                       tui ;;
	       "3)")   clear
		       drop $1 ;;
	       "4)")   clear
		       insert $1 ;;
	       "5)")   clear
		       select_from $1 ;;
	       "6)")   clear
		       update_table $1;;
	       "7)")   clear
		       delete $1 ;;
	       "8)") tui ;;
		 *) whiptail --msgbox "Invalid input" 10 100
			 tui ;;
	 esac
 fi
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
function drop {
db_path="$1"

read -p "Enter table name: " d_name
if [[ $d_name =~ $regex ]]
then
        if [[ -f "$db_path"/"$d_name" ]]
        then
		echo "Are you sure you want to permenently delete table $d_name"
		select ans in "yes" "no"
		do
		   case $REPLY in
			   1) rm -f "$db_path"/"$d_name" ;;
			   2) echo "Returning to connection menu"
				   "$db_path"/"$d_name";;
			   *) echo "Invaild input" ;;
		   esac
	   done
	else
		echo "Table does not exist"
	fi
else
    echo "Invaild input"
fi

}

function delete {

db_path="$1"

read -p "Enter table name: " d_name
if [[ $d_name =~ $regex ]]
then
        if [[ -f "$db_path"/"$d_name" ]]
        then
                clear
        echo    "==================================================="
        echo    "                table $d_name data                 "
        echo    "==================================================="
       awk -F":" 'BEGIN{OFS=" | "; ORS="\n-------------\n"} {if(NR!=2 && NR!=3){$1=$1; print $0}}' "$db_path"/"$d_name"
              row_num=`awk -F":" 'END{print NR}' "$db_path"/"$d_name"`
	      echo -ne "\n"
                select del in "Delete by row number" "Delete by column name" "Delete all"
                do
                        case $REPLY in
                          1) read -p "Enter the number of the row you want to delete: " row
                                if [[ $row =~ ^[0-9]+$ ]]
                                then
                                  var=$((row+3))
                                 if [[ $var -le $row_num ]]
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
                          2) read -p "Enter the name of the column you want to delete: " colu

                                  key=`awk -F":" '{if(NR==3) print $1}'  $db_path/$d_name`
                                  num_colu=`awk -F":" '{if (NR==1) print NF}' $db_path/$d_name`
                                  check=`awk -v num_colu=$num_colu -v colu=$colu -F":" '{

                        if (NR==1) {
                                for (i=1;i<=num_colu;i++)
                                        {
                                if ( $i == colu ) print 1
                                        }
                                   }    
                        }' "$db_path"/"$d_name"`
                        if [[ $check -eq 1 ]]
                        then
                        colu_num=`awk -v num_colu=$num_colu -v colu=$colu -F":" '{
                        if (NR==1) {
                                for (i=1;i<=num_colu;i++)
                                        {
                                if ( $i == colu ) print i
                                        }
                                   }    
                        }' "$db_path"/"$d_name"`
                                if [[ $colu_num -eq $key ]]
                                then
                                        echo "You can not delete the primary key column"
                                else
        awk -i inplace -v i=$colu_num -v OFS=":" -F":" '{if(NR != 3) {$i=""}; print $0}' "$db_path"/"$d_name"
                                        sed -i 's/::/:/g' "$db_path"/"$d_name"
                                        sed -i 's/^://' "$db_path"/"$d_name"
                                        sed -i 's/:$//' "$db_path"/"$d_name"
                                fi
                        else
                                echo "Column does not exist"
                        fi
                        ;;
                          3) echo "Are you sure you want to delete the entire table data"
                                  select choice in "yes" "no"
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

echo "Values deleted successfully"

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


function tui {

CHOICE=$(whiptail --menu --title "DBMS TUI-Version" "Choose an option" 18 100 10 \
  "1" "Create database" \
  "2" "List databases" \
  "3" "Connect to a database" \
  "4" "Drop database" \
  "5" "Exit" 3>&1 1>&2 2>&3)

if [ -z "$CHOICE" ]; then
        whiptail --msgbox "No option was selected" 10 100
else
         case "$CHOICE" in
    "1")
            NAME=$(whiptail --inputbox "Enter the database name: " 10 100 3>&1 1>&2 2>&3)
            if [[ $NAME =~ ^[a-zA-Z]+$ ]]
                        then

                                if [[ -d ./DBMS/$NAME ]]
                                then
                                  whiptail --msgbox  "Databas already exists" 10 100
                                  tui
                                else
                                        mkdir ./DBMS/$NAME
                                        {
                                         for ((i=0; i<=100; i+=1)); do
                                        sleep 0.04
                                           echo $i
                                        done
                                        } |  whiptail --title "Creating database" --gauge "Database $NAME is being created" 6 60 0
                                   whiptail --msgbox  " Database $NAME is created successfully " 10 100
                                  tui
                                fi
                        else

                          whiptail --msgbox "Syntax Error Invalid name for database!\nReturning to main menu" 10 100
                                  tui
                        fi

      ;;

    "2")
                whiptail --msgbox "$(ls ./DBMS)" 10 100
                tui
      ;;

    "3")
            
           db_name=$(whiptail --inputbox "Enter the database name: " 10 100 3>&1 1>&2 2>&3)
	   if [ -z $db_name ]
	   then
		 
		  whiptail --msgbox "Database name can not be empty!" 10 100
		  tui	
	   else
                if [[ -d ./DBMS/$db_name ]]
                        then
                               subsidiary ./DBMS/$db_name $db_name
                        else
                        whiptail --msgbox "Database $db_name does not exist" 10 100
			tui
                        fi
	  fi

      ;;

    "4")
            name=$(whiptail --inputbox "Enter the database name: " 10 100 3>&1 1>&2 2>&3)
                if [[ -d ./DBMS/$name ]]
                 then
                     if whiptail --yesno "Are you sure you want to permanently delete $name" 10 100 --defaultno; then
                             rm -rf ./DBMS/$name
                             whiptail --msgbox "Database $name deleted successfully!" 10 100
                             tui

                     fi
                 fi

      ;;

    "5")
            exit
      ;;

    *)
       whiptail --msgbox "Invaild input" 10 100
      ;;

    esac
fi
}
tui

