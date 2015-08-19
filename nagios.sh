#!/bin/bash
OPTION=$1

function main_menu {
	_choice=$( dialog \
				--stdout \
				--title 'Options' \
				--menu 'Choose an action:' \
				0 0 0 \
				1 'Add new hostgroup' \
				2 'Add new host' \
				3 'Add new service' \
				0 'Exit' )

	case $_choice in
		'1') add_hostgroup ;;
		'2') add_host ;;
		'3') add_service ;;
		'0') exit ;;
	esac

}

function add_host {
	_hostname=$( dialog \
					--stdout \
					--title "Add Host" \
					--inputbox "Hostname:" \
					0 0 ) 

	_hostgroups=$( dialog \
						--stdout \
						--title "Add Host" \
						--inputbox "Hostgroups: (for more than one, put then separeted by comma)" \
						0 0 )

	printf "define host { \n\
					use generic-host \n\
					host_name $_hostname \n\
					hostgroups	$_hostgroups\n}\n\n" >> $OPTION

	main_menu
}

function add_hostgroup {
	_hostgroupname=$( dialog \
							--stdout \
							--title "Add Hostgroup:" \
							--inputbox "Name:" \
							0 0 )

	_alias=$( dialog \
				--stdout \
				--title "Add Hostgroup:" \
				--inputbox "Alias:" \
				0 0 )

	printf "define hostgroup { \n\
				hostgroup_name	$_hostgroupname \n\
				alias $_alias \n}\n\n" >> $OPTION

	main_menu
}

function add_service {
	_list_commands='dialog --title "Available commands" --menu "Which command do you want do use?" 0 0 0'
	_available_commands=$(ls /usr/lib/nagios/plugins/ | xargs -i echo '{} "{}"')

	_description=$( dialog \
						--stdout \
						--title "Add Service:" \
						--inputbox "Description:" \
						0 0 )

	_hostgroupname=$( dialog \
							--stdout \
							--title "Add Service:" \
							--inputbox "Name:" \
							0 0 )

	echo $_available_commands[@] >> log2.log	
	_command=$( dialog --stdout --title "Available commands" --menu "Which command do you want do use?" 0 0 0 $_available_commands[@] )

	_commandargs=$( dialog \
					--stdout \
					--title "Add Service:" \
					--inputbox "Check command:"\
					0 0 )

	printf "define service { \n\
				service_description $_description \n\
				use	generic-service \n\
				hostgroup_name $_hostgroupname \n\
				check_command $_command$_commandargs \n}\n\n" >> $OPTION

	service nagios3 reload
	main_menu
}

if [ -n "$OPTION" ]; then
	main_menu
else
	echo 'You must pass the Nagios config file'
	exit
fi
