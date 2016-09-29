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

###########################
## Initial menu Function ##
###########################

init(){

		$echo "\nWP Cly\n"
		$echo "Select Option Below:\n"
		$echo "  (1) Install Wordpress"
		$echo "  (2) Update Wordpress (core)"
		$echo "  (3) Vulnerability Scan"
		$echo "  (4) Update Plugins"
		$echo "  (5) Exit\n"
		$echo -n "Select: "
		read init_option

	if [ -z $init_option ] ; then
		clear
		$echo "Invalid option"
		init
	else
		$echo "You have selected $init_option"
	fi

	if ! [ $init_option -ge 1 -a $init_option -le 5 ]; then
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
		wpscan_func
		
	fi

	if [ $init_option = "4" ]; then
		clear
		wp_plugin_update_check
	fi
	
	if [ $init_option = "5" ]; then
		clear
		exit
	fi
}

#####################################
## Wordpress installation function ##
#####################################

wp_install(){

	if [[ ( -f wp-config.php ) || ( -f wp-config-sample.php ) ]]; then
		
		$echo "\nWordpress looks to be installed in this directory\nExiting"
		exit

	fi

		$echo "\nEnter Root MySQL Password:\n "
		read -s 'mypass'

		mysql="/usr/bin/mysql -p$mypass -e"

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

		$mysql "create database $db_name"
		sleep 2;
	
		$echo "Created Database $db_name\n"


		$mysql "create user '$db_username'@'localhost' identified by '$db_password'"
		sleep 2;

		$echo "Created MySQL User $db_username\n"


		$mysql "grant all on $db_name.* to '$db_username'@'localhost'"


		$mysql "flush privileges"
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

		wp core download --version=$wp_install_version
		sleep 2;

		wp core config --dbuser=$db_username --dbname=$db_name --dbpass=$db_password

		sleep 2;

		wp core install --url=$site_url --title="$site_title" --admin_user=$admin_user --admin_password=$admin_password --admin_email=$admin_email

		init
}

###########################################
## Function to check major core updates ##
###########################################

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

##########################################
## Function to check minor core updates ##
##########################################

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

###########################################
## Function to perform major core update ##
###########################################

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

###########################################
## Function to perform minor core update ##
###########################################

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

################################################
## Function to check available plugin updates ##
################################################

wp_plugin_update_check(){

		$echo "Checking Plugin Updates..\n"

		wp plugin list | awk '{ print $2,$6}' | grep available &> /dev/null

	if [[ $? == 0 ]]; then	

		$echo "Plugin(s) with Update Available\n" 

		wp plugin list  | sed '/none/d'


		$echo "Would you like to update outdated plugins?\n"
		$echo "(y/n)"
	
		read pluginupopt

	if [ $pluginupopt == y ]; then

		wp_plugin_update
		
	else

		clear
		init

	fi

	else
		$echo "All plugins up to date.\n"
		wp plugin list
		init	
	fi


}

##############################################
## Function to perform the plugin update(s) ##
##############################################

wp_plugin_update(){


        	$echo "Updating Plugins..\n"

        for i in `wp plugin list | grep available | awk '{ print $2 }'`

        do

        	wp plugin update $i

        done
	
		init
}

################################################
## Function to performm a WPScan on wp in cwd ##
################################################

wpscan_func(){

		wp_siteurl=`wp option get siteurl`
	
		$echo "Starting WPScan Vulnerability Scan on $wp_siteurl...\n"
       		ssh root@104.236.105.85 "cd /var/www/html/wpscan && ./wpscan.sh $wp_siteurl 2>&1"  
     	

		init
}


check
