# provision.sh
#
# This file is specified in Vagrantfile and is loaded by Vagrant as the primary
# provisioning script whenever the commands `vagrant up`, `vagrant provision`,
# or `vagrant reload` are used. It provides all of the default packages and
# configurations included with Varying Vagrant Vagrants.

# By storing the date now, we can calculate the duration of provisioning at the
# end of this script.
start_seconds=`date +%s`

# Capture a basic ping result to Google's primary DNS server to determine if
# outside access is available to us. If this does not reply after 2 attempts,
# we try one of Level3's DNS servers as well. If neither of these IPs replies to
# a ping, then we'll skip a few things further in provisioning rather than
# creating a bunch of errors.
ping_result=`ping -c 2 8.8.4.4 2>&1`
if [[ $ping_result != *bytes?from* ]]
then
	ping_result=`ping -c 2 4.2.2.2 2>&1`
fi

sudo apt-get update

sudo apt-get -y install apache2
sudo sh -c 'echo "ServerName localhost" >> /etc/apache2/conf.d/name'

# MySQL
#
# Use debconf-set-selections to specify the default password for the root MySQL
# account. This runs on every provision, even if MySQL has been installed. If
# MySQL is already installed, it will not affect anything. 
echo mysql-server mysql-server/root_password password root | debconf-set-selections
echo mysql-server mysql-server/root_password_again password root | debconf-set-selections

sudo apt-get -y install mysql-server

sudo apt-get -y install php5

sudo apt-get -y install libapache2-mod-php5
sudo apt-get -y install php5-mysql

sudo apt-get -y install php-pear
sudo apt-get -y install php5-xdebug
sudo apt-get -y install curl
sudo apt-get -y install unzip
sudo apt-get -y install subversion
sudo apt-get -y install git
sudo apt-get -y install vim

#apache configuration
# activate mod_rewrite
if [ ! -L /etc/apache2/mods-enabled/rewrite.load ]; then
    sudo ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
fi

# load vhosts
HOSTFILES=/srv/config/apache-config/*
for f in $HOSTFILES
do
	filename=$(basename "$f")
	filename=${filename%.*}
    sudo ln -sf $f /etc/apache2/sites-enabled/$filename
    echo " * $f -> /etc/apache2/sites-enabled/$filename"
done

# symlink www
# sudo ln -s /var/www /srv/www
# 
if [[ $ping_result == *bytes?from* ]]; then

	# COMPOSER
	#
	# Install or Update Composer based on current state. Updates are direct from
	# master branch on GitHub repository.
	if [[ -n "$(composer --version | grep -q 'Composer version')" ]]; then
		echo "Updating Composer..."
		composer self-update
	else
		echo "Installing Composer..."
		curl -sS https://getcomposer.org/installer | php
		chmod +x composer.phar
		mv composer.phar /usr/local/bin/composer
	fi

	# PHPUnit
	#
	# Check that PHPUnit, Mockery, and Hamcrest are all successfully installed.
	# If not, then Composer should be given another shot at it. Versions for
	# these packages are controlled in `/srv/config/phpunit-composer.json`.
	if [[ ! -d /usr/local/src/vvv-phpunit ]]; then
		echo "Installing PHPUnit, Hamcrest and Mockery..."
		mkdir -p /usr/local/src/vvv-phpunit
		cp /srv/config/phpunit-composer.json /usr/local/src/vvv-phpunit/composer.json
		sh -c "cd /usr/local/src/vvv-phpunit && composer install"
	else
		cd /usr/local/src/vvv-phpunit
		if [[ -n "$(composer show -i | grep -q 'mockery')" ]]; then
			echo "Mockery installed"
		else
			vvvphpunit_update=1
		fi
		if [[ -n "$(composer show -i | grep -q 'phpunit')" ]]; then
			echo "PHPUnit installed"
		else
			vvvphpunit_update=1
		fi
		if [[ -n "$(composer show -i | grep -q 'hamcrest')" ]]; then
			echo "Hamcrest installed"
		else
			vvvphpunit_update=1
		fi
		cd ~/
	fi

	if [[ "$vvvphpunit_update" = 1 ]]; then
		echo "Update PHPUnit, Hamcrest and Mockery..."
		cp /srv/config/phpunit-composer.json /usr/local/src/vvv-phpunit/composer.json
		sh -c "cd /usr/local/src/vvv-phpunit && composer update"
	fi

	# Grunt
	#
	# Install or Update Grunt based on gurrent state.  Updates are direct
	# from NPM
	if [[ "$(grunt --version)" ]]; then
		echo "Updating Grunt CLI"
		npm update -g grunt-cli &>/dev/null
		npm update -g grunt-sass &>/dev/null
		npm update -g grunt-cssjanus &>/dev/null
	else
		echo "Installing Grunt CLI"
		npm install -g grunt-cli &>/dev/null
		npm install -g grunt-sass &>/dev/null
		npm install -g grunt-cssjanus &>/dev/null
	fi
else
	echo -e "\nNo network connection available, skipping package installation"
fi


# Copy custom dotfiles and bin file for the vagrant user from local
cp /srv/config/bash_profile /home/vagrant/.bash_profile
cp /srv/config/bash_aliases /home/vagrant/.bash_aliases
cp /srv/config/vimrc /home/vagrant/.vimrc
if [[ ! -d /home/vagrant/.subversion ]]; then
	mkdir /home/vagrant/.subversion
fi
cp /srv/config/subversion-servers /home/vagrant/.subversion/servers
if [[ ! -d /home/vagrant/bin ]]; then
	mkdir /home/vagrant/bin
fi
rsync -rvzh --delete /srv/config/homebin/ /home/vagrant/bin/

echo " * /srv/config/bash_profile                      -> /home/vagrant/.bash_profile"
echo " * /srv/config/bash_aliases                      -> /home/vagrant/.bash_aliases"
echo " * /srv/config/vimrc                             -> /home/vagrant/.vimrc"
echo " * /srv/config/subversion-servers                -> /home/vagrant/.subversion/servers"
echo " * /srv/config/homebin                           -> /home/vagrant/bin"


# RESTART SERVICES
#
# Make sure the services we expect to be running are running.
echo -e "\nRestart services..."
sudo service apache2 restart


# SYMLINK HOST FILES
echo -e "\nSetup configuration file links..."

# Capture the current IP address of the virtual machine into a variable that
# can be used when necessary throughout provisioning.
vvv_ip=`ifconfig eth1 | ack "inet addr" | cut -d ":" -f 2 | cut -d " " -f 1`

# Disable PHP Xdebug module by default
#php5dismod xdebug
#service php5-fpm restart

# If MySQL is installed, go through the various imports and service tasks.
exists_mysql="$(service mysql status)"
if [[ "mysql: unrecognized service" != "${exists_mysql}" ]]; then
	echo -e "\nSetup MySQL configuration file links..."

	# Copy mysql configuration from local
	cp /srv/config/mysql-config/my.cnf /etc/mysql/my.cnf
	cp /srv/config/mysql-config/root-my.cnf /home/vagrant/.my.cnf

	echo " * /srv/config/mysql-config/my.cnf               -> /etc/mysql/my.cnf"
	echo " * /srv/config/mysql-config/root-my.cnf          -> /home/vagrant/.my.cnf"

	# MySQL gives us an error if we restart a non running service, which
	# happens after a `vagrant halt`. Check to see if it's running before
	# deciding whether to start or restart.
	if [[ "mysql stop/waiting" == "${exists_mysql}" ]]; then
		echo "service mysql start"
		service mysql start
	else
		echo "service mysql restart"
		service mysql restart
	fi

	# IMPORT SQL
	#
	# Create the databases (unique to system) that will be imported with
	# the mysqldump files located in database/backups/
	if [[ -f /srv/database/init-custom.sql ]]; then
		mysql -u root -proot < /srv/database/init-custom.sql
		echo -e "\nInitial custom MySQL scripting..."
	else
		echo -e "\nNo custom MySQL scripting found in database/init-custom.sql, skipping..."
	fi

	# Setup MySQL by importing an init file that creates necessary
	# users and databases that our vagrant setup relies on.
	mysql -u root -proot < /srv/database/init.sql
	echo "Initial MySQL prep..."

	# Process each mysqldump SQL file in database/backups to import
	# an initial data set for MySQL.
	/srv/database/import-sql.sh
else
	echo -e "\nMySQL is not installed. No databases imported."
fi

if [[ $ping_result == *bytes?from* ]]; then
	# WP-CLI Install
	if [[ ! -d /srv/www/wp-cli ]]; then
		echo -e "\nDownloading wp-cli, see http://wp-cli.org"
		git clone git://github.com/wp-cli/wp-cli.git /srv/www/wp-cli
		cd /srv/www/wp-cli
		composer install
	else
		echo -e "\nUpdating wp-cli..."
		cd /srv/www/wp-cli
		git pull --rebase origin master
		composer update
	fi
	# Link `wp` to the `/usr/local/bin` directory
	ln -sf /srv/www/wp-cli/bin/wp /usr/local/bin/wp

	# Download and extract phpMemcachedAdmin to provide a dashboard view and
	# admin interface to the goings on of memcached when running
	if [[ ! -d /srv/www/default/memcached-admin ]]; then
		echo -e "\nDownloading phpMemcachedAdmin, see https://code.google.com/p/phpmemcacheadmin/"
		cd /srv/www/default
		wget -q -O phpmemcachedadmin.tar.gz 'https://phpmemcacheadmin.googlecode.com/files/phpMemcachedAdmin-1.2.2-r262.tar.gz'
		mkdir memcached-admin
		tar -xf phpmemcachedadmin.tar.gz --directory memcached-admin
		rm phpmemcachedadmin.tar.gz
	else
		echo "phpMemcachedAdmin already installed."
	fi

	# Webgrind install (for viewing callgrind/cachegrind files produced by
	# xdebug profiler)
	if [[ ! -d /srv/www/default/webgrind ]]; then
		echo -e "\nDownloading webgrind, see https://github.com/jokkedk/webgrind"
		git clone git://github.com/jokkedk/webgrind.git /srv/www/default/webgrind
	else
		echo -e "\nUpdating webgrind..."
		cd /srv/www/default/webgrind
		git pull --rebase origin master
	fi

	# PHP_CodeSniffer (for running WordPress-Coding-Standards)
	if [[ ! -d /srv/www/phpcs ]]; then
		echo -e "\nDownloading PHP_CodeSniffer (phpcs), see https://github.com/squizlabs/PHP_CodeSniffer"
		git clone git://github.com/squizlabs/PHP_CodeSniffer.git /srv/www/phpcs
	else
		echo -e "\nUpdating PHP_CodeSniffer (phpcs)..."
		cd /srv/www/phpcs
		git pull --rebase origin master
	fi

	# Sniffs WordPress Coding Standards
	if [[ ! -d /srv/www/phpcs/CodeSniffer/Standards/WordPress ]]; then
		echo -e "\nDownloading WordPress-Coding-Standards, snifs for PHP_CodeSniffer, see https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards"
		git clone git://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git /srv/www/phpcs/CodeSniffer/Standards/WordPress
	else
		echo -e "\nUpdating PHP_CodeSniffer..."
		cd /srv/www/phpcs/CodeSniffer/Standards/WordPress
		git pull --rebase origin master
	fi

	# Install and configure the latest stable version of WordPress
	if [[ ! -d /srv/www/wordpress-default ]]; then
		echo "Downloading WordPress Stable, see http://wordpress.org/"
		cd /srv/www/
		curl -O http://wordpress.org/latest.tar.gz
		tar -xvf latest.tar.gz
		mv wordpress wordpress-default
		rm latest.tar.gz
		cd /srv/www/wordpress-default
		echo "Configuring WordPress Stable..."
		wp core config --dbname=wordpress_default --dbuser=wp --dbpass=wp --quiet --extra-php <<PHP
define( 'WP_DEBUG', true );
PHP
		wp core install --url=local.wordpress.dev --quiet --title="Local WordPress Dev" --admin_name=admin --admin_email="admin@local.dev" --admin_password="password"
	else
		echo "Updating WordPress Stable..."
		cd /srv/www/wordpress-default
		wp core upgrade
	fi

	# Checkout, install and configure WordPress trunk via core.svn
	if [[ ! -d /srv/www/wordpress-trunk ]]; then
		echo "Checking out WordPress trunk from core.svn, see http://core.svn.wordpress.org/trunk"
		svn checkout http://core.svn.wordpress.org/trunk/ /srv/www/wordpress-trunk
		cd /srv/www/wordpress-trunk
		echo "Configuring WordPress trunk..."
		wp core config --dbname=wordpress_trunk --dbuser=wp --dbpass=wp --quiet --extra-php <<PHP
define( 'WP_DEBUG', true );
PHP
		wp core install --url=local.wordpress-trunk.dev --quiet --title="Local WordPress Trunk Dev" --admin_name=admin --admin_email="admin@local.dev" --admin_password="password"
	else
		echo "Updating WordPress trunk..."
		cd /srv/www/wordpress-trunk
		svn up --ignore-externals
	fi

	# Checkout, install and configure WordPress trunk via develop.svn
	if [[ ! -d /srv/www/wordpress-develop ]]; then
		echo "Checking out WordPress trunk from develop.svn, see http://develop.svn.wordpress.org/trunk"
		svn checkout http://develop.svn.wordpress.org/trunk/ /srv/www/wordpress-develop
		cd /srv/www/wordpress-develop/src/
		echo "Configuring WordPress develop..."
		wp core config --dbname=wordpress_develop --dbuser=wp --dbpass=wp --quiet --extra-php <<PHP
// Allow (src|build).wordpress-develop.dev to share the same database
if ( 'build' == basename( dirname( __FILE__) ) ) {
	define( 'WP_HOME', 'http://build.wordpress-develop.dev' );
	define( 'WP_SITEURL', 'http://build.wordpress-develop.dev' );
}

define( 'WP_DEBUG', true );
PHP
		wp core install --url=src.wordpress-develop.dev --quiet --title="WordPress Develop" --admin_name=admin --admin_email="admin@local.dev" --admin_password="password"
		cp /srv/config/wordpress-config/wp-tests-config.php /srv/www/wordpress-develop/
		cd /srv/www/wordpress-develop/
		npm install &>/dev/null
	else
		echo "Updating WordPress develop..."
		cd /srv/www/wordpress-develop/
		svn up
		npm install &>/dev/null
	fi

	if [[ ! -d /srv/www/wordpress-develop/build ]]; then
		echo "Initializing grunt in WordPress develop... This may take a few moments."
		cd /srv/www/wordpress-develop/
		grunt
	fi

	# Download phpMyAdmin
	if [[ ! -d /srv/www/default/database-admin ]]; then
		echo "Downloading phpMyAdmin 4.0.10..."
		cd /srv/www/default
		wget -q -O phpmyadmin.tar.gz 'http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.0.10/phpMyAdmin-4.0.10-all-languages.tar.gz/download'
		tar -xf phpmyadmin.tar.gz
		mv phpMyAdmin-4.0.10-all-languages database-admin
		rm phpmyadmin.tar.gz
	else
		echo "PHPMyAdmin already installed."
	fi
	cp /srv/config/phpmyadmin-config/config.inc.php /srv/www/default/database-admin/
else
	echo -e "\nNo network available, skipping network installations"
fi

# Look for site setup scripts
for SITE_CONFIG_FILE in $(find /srv/www -maxdepth 5 -name 'vvv-init.sh'); do
	DIR="$(dirname $SITE_CONFIG_FILE)"
	(
		cd $DIR
		bash vvv-init.sh
	)
done

# Look for Nginx vhost files, symlink them into the custom sites dir
for SITE_CONFIG_FILE in $(find /srv/www -maxdepth 5 -name 'vvv-nginx.conf'); do
	DEST_CONFIG_FILE=${SITE_CONFIG_FILE//\/srv\/www\//}
	DEST_CONFIG_FILE=${DEST_CONFIG_FILE//\//\-}
	DEST_CONFIG_FILE=${DEST_CONFIG_FILE/%-vvv-nginx.conf/}
	DEST_CONFIG_FILE="vvv-auto-$DEST_CONFIG_FILE-$(md5sum <<< $SITE_CONFIG_FILE | cut -c1-32).conf"
	# We allow the replacement of the {vvv_path_to_folder} token with
	# whatever you want, allowing flexible placement of the site folder
	# while still having an Nginx config which works.
	DIR="$(dirname $SITE_CONFIG_FILE)"
	sed "s#{vvv_path_to_folder}#$DIR#" $SITE_CONFIG_FILE > /etc/nginx/custom-sites/$DEST_CONFIG_FILE
done

# RESTART SERVICES AGAIN
#
# Make sure the services we expect to be running are running.
echo -e "\nRestart Apache2..."
sudo service apache2 restart

# Parse any vvv-hosts file located in www/ or subdirectories of www/
# for domains to be added to the virtual machine's host file so that it is
# self aware.
#
# Domains should be entered on new lines.
echo "Cleaning the virtual machine's /etc/hosts file..."
sed -n '/# vvv-auto$/!p' /etc/hosts > /tmp/hosts
mv /tmp/hosts /etc/hosts
echo "Adding domains to the virtual machine's /etc/hosts file..."
find /srv/www/ -maxdepth 5 -name 'vvv-hosts' | \
while read hostfile; do
	while IFS='' read -r line || [ -n "$line" ]; do
		if [[ "#" != ${line:0:1} ]]; then
			if [[ -z "$(grep -q "^127.0.0.1 $line$" /etc/hosts)" ]]; then
				echo "127.0.0.1 $line # vvv-auto" >> /etc/hosts
				echo " * Added $line from $hostfile"
			fi
		fi
	done < $hostfile
done

end_seconds="$(date +%s)"
echo "-----------------------------"
echo "Provisioning complete in "$(expr $end_seconds - $start_seconds)" seconds"
if [[ $ping_result == *bytes?from* ]]; then
	echo "External network connection established, packages up to date."
else
	echo "No external network available. Package installation and maintenance skipped."
fi
echo "For further setup instructions, visit http://vvv.dev"
