#!/bin/bash

alias echo='echo -e'

check(){

	if [ -f /usr/local/bin/wp ]; then
		clear
		init	

	else
		clear
		exit
		echo "wp-cli not present.  exiting."

	fi
}

init(){

		echo "\nWP Cly\n"
		echo "Select Option Below:\n"
		echo "  (1) Install Wordpress"
		echo "  (2) Update Wordpress"
		echo "  (3) A La Carte"
		echo "  (4) Exit\n"
		echo -n "Select: "
		read init_option

	if [ -z $init_option ] ; then
		clear
		echo "Invalid option"
		init
	else
		echo "You have selected $init_option"
	fi

	if ! [ $init_option -ge 1 -a $init_option -le 4 ]; then
		clear
		echo "Invalid option"
		init
	fi


	if [ $init_option = "1" ]; then
		clear
		wp_install
	fi

	if [ $init_option = "2" ]; then
		clear
		wp_update	

	fi

	if [ $init_option = "3" ]; then
		clear
		a_la_carte
		
	fi

	if [ $init_option = "4" ]; then
		clear
		exit

	fi
}


wp_install(){

	
		echo "\nThis Will Install the latest  Wordpress version\n in the current working directory\n"

		echo "Enter Database name:\n"
		read db_name

		echo "Enter MySQL Username:\n"
		read db_username

		echo "Enter MySQL User Password:\n"
		read db_password


/usr/bin/mysql -e "create database $db_name"

		sleep 2;
	
		echo "Created Database $db_name\n"


/usr/bin/mysql -e "create user '$db_username'@'localhost' identified by '$db_password'"

		sleep 2;

		echo "Created MySQL User $db_username\n"


/usr/bin/mysql -e "grant all on $db_name.* to '$db_username'@'localhost'"



/usr/bin/mysql -e "flush privileges"

		sleep 2;

		echo "Privileges Granted"


		echo "Enter Wordpress Installation Details:\n"

		echo "Site URL: "
		read site_url

		echo "Site Title: "
		read site_title

		echo "Admin Username: "
		read admin_user

		echo "Admin Password: "
		read admin_password

		echo "Admin Email Address: "
		read admin_email

		sleep 2;

		echo "Installing Wordpress.."

	/usr/local/bin/wp core download
		sleep 2;

	/usr/local/bin/wp core config --dbuser=$db_username --dbname=$db_name --dbpass=$db_password

		sleep 2;

	/usr/local/bin/wp core install --url=$site_url --title=$site_title --admin_user=$admin_user --admin_password=$admin_password --admin_email=$admin_email

}
wp_update(){

		echo "Update Function"
}

a_la_carte(){

		echo "A La Carte Function"
}

check
