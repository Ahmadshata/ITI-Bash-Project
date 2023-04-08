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
							fi