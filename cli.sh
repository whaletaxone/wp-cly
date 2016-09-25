#!/bin/bash

#####################################
# This is a bash wrapper for wp-cli #
#####################################

echo='echo -e'

##################################
# Check that wp-cli is installed #
##################################

check(){

	wp --info | grep -i "wp-cli version" &> /dev/null

		if  [ $? == 0 ]; then
		
		clear
		init

		else

		$echo "wp-cli isn't installed\n"
		exit
		
		fi
}

####################
# Initial Function #
####################

init(){

		$echo "\nWP Cly\n"
		$echo "Select Option Below:\n"
		$echo "  (1) Install Wordpress"
		$echo "  (2) Update Wordpress"
		$echo "  (3) A La Carte"
		$echo "  (4) Exit\n"
		$echo -n "Select: "
		read init_option

	if [ -z $init_option ] ; then
		clear
		$echo "Invalid option"
		init
	else
		$echo "You have selected $init_option"
	fi

	if ! [ $init_option -ge 1 -a $init_option -le 4 ]; then
		clear
		$echo "Invalid option"
		init
	fi

	if [ $init_option = "1" ]; then
		clear
		wp_install
	fi

	if [ $init_option = "2" ]; then
		clear
		wp_update_check	

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


		$echo "\nEnter Root MySQL Password:\n "
		read 'mypass'


		$echo "What version?"
		$echo "Latest(1)/Previous(2): "
		read wp_install_version
		
		if [ $wp_install_version == 1 ]; then

		wp_install_version="latest"

		else

		$echo "Which one? ex. 4.2 : "
		read wp_install_version
		fi
	
		$echo "\nThis Will Install the $wp_install_version Wordpress version\n in the current working directory\n"

		$echo "Enter Database name:\n"
		read db_name

		$echo "Enter MySQL Username:\n"
		read db_username

		$echo "Enter MySQL User Password:\n"
		read db_password

/usr/bin/mysql -p$mypass -e "create database $db_name"

		sleep 2;
	
		$echo "Created Database $db_name\n"


/usr/bin/mysql -p$mypass -e "create user '$db_username'@'localhost' identified by '$db_password'"

		sleep 2;

		$echo "Created MySQL User $db_username\n"


/usr/bin/mysql -p$mypass -e "grant all on $db_name.* to '$db_username'@'localhost'"



/usr/bin/mysql  -p$mypass -e "flush privileges"

		sleep 2;

		$echo "Privileges Granted"


		$echo "Enter Wordpress Installation Details:\n"

		$echo "Site URL: "
		read site_url

		$echo "Site Title: "
		read site_title

		$echo "Admin Username: "
		read admin_user

		$echo "Admin Password: "
		read admin_password

		$echo "Admin Email Address: "
		read admin_email

		sleep 2;

		$echo "Installing Wordpress.."

	/usr/local/bin/wp core download --version=$wp_install_version
		sleep 2;

	/usr/local/bin/wp core config --dbuser=$db_username --dbname=$db_name --dbpass=$db_password

		sleep 2;

	/usr/local/bin/wp core install --url=$site_url --title="$site_title" --admin_user=$admin_user --admin_password=$admin_password --admin_email=$admin_email

}

wp_update_check(){

wp core check-update --major | grep -i 'success' &> /dev/null

       	if [[ $? == 0 ]]; then

       	$echo "Major Version up to date"
       	wp_update_check2
        else

       	$echo "Major Version not up to date"
       	majorup="1"
       	wp_update_major

       	fi
}

wp_update_check2(){

wp core check-update --minor | grep -i 'success' &> /dev/null

       	if [[ $? == 0 ]]; then

       	$echo "Minor Version up to date"
       	init

       	else

       	$echo "Minor Version not up to date" ;
       	minorup="1"
       	wp_update_minor

       	fi

}

wp_update_major(){

current_version=`wp core version`


       	wp core check-update --major

       	$echo "Current installed version $current_version \n"
       	$echo "Update to latest version?\n"
       	$echo "y/n\n"
       	read upanswer

       	if [ $upanswer == "y" ]; then

       	wp core update

       	else

       	clear
       	init
fi
}

wp_update_minor(){

current_version=`wp core version`


        wp core check-update --minor

        $echo "Current installed version: $current_version \n"
        $echo "Update to latest version?\n"
        $echo "y/n\n"
        read upanswer

        if [ $upanswer == "y" ]; then

        wp core update --minor


        else

        clear
        init
fi
}


a_la_carte(){

		$echo "A La Carte Function"
}

check
