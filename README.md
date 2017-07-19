> Note:  This repository is no longer actively maintained and likely won't work as expected for your needs. Feel free to fork it and play around with it if needed but it's considered a dead project.

## Varying Vagrant Vagrants Apache

Varying Vagrant Vagrants Apache simply adds an apache/PHP5.3 box to VVV.  Pretty much follows the same provisioning except using apache and PHP5.3 instead of nginx and PHP5.4

The neat thing about this fork, is you can do this:

`vagrant up php54` 
**loads up the original VVV***

OR

`vagrant up php53`
**loads up the new apache and php53 VVV***

In both cases, the same /www/ folders/file setups, and databases are used.

How?  [Via this](http://docs.vagrantup.com/v2/multi-machine/index.html)

I also used some provisioning instructions from https://github.com/ifeelweb/ifwWordPressDevEnvironment and mish mashed what was included with VVV.

*NOTE*: this is very hackish as I'm NOT a server guru.  I just wanted to get a way to do development on either apache 5.3/PHP5.3 or the default nginx/PHP5.4 setups.

Some other important things:

* I've used the "Customfile" option available for VVV steup.  In Customfile is the magic for provisioning either as a php53 or php54 box.
* the default provision is in the original file.  The provisioning stuff for apache/php5.3 is found in `provision53.sh`. You can still have custom pre and post provision scripts.  Usage is the same as the original except you prepend "-53" to the script name (i.e. `provision-pre-53.sh` or `provision-post-53.sh`)
* custom db imports/site setup works the same as default VVV however, you will want to make any modifications to the "Virtual Hosts" for any custom domains.  To do so go to `config/apache-config/apachehosts.vhost` and add in your VirtualHost instructions in there.
* **DO NOT** have both boxes running at the same time.  While it's possible to start them both up, they are both setup to share the same domains/ip address and obviously that will make things not work.  So don't blow up the universe.  Just use one box at a time (get familiar with `vagrant suspend` and `vagrant resume`)
* for an example of how to setup a domain that works with multiple subdirectories (for fast provisioning of multiple wp installs, see what i did with the wp.dev domain).  Note, that if you add a sub-folder to the /www/ directory and install wordpress in it then `wp.dev/sub-folder/` will automatically work with apache/php53 for permalinks.  Permalinks will also work with the nginx setup, however you do have to add the subdirectory to `www/vvv-nginx.conf/` using the same format in there as what I've already put in there. Make sure you either re provision your vm or restart the nginx service after your change.

### How can you help?

Here's a point list of things that I'd love help from folks on implementing:

* Make it so you can add multiple WordPress versions installed in subdirectories to the /www/ root without requiring any edits of nginx.conf to get the permalinks working for those dirs when accessed via the same domain.
* It'd be nice to have an apache/PHP5.2 box for being able to test on.  But what would be nicer is if WP just dropped support for PHP5.2!


# Varying Vagrant Vagrants

Varying Vagrant Vagrants is an evolving [Vagrant](http://vagrantup.com) configuration focused on [WordPress](http://wordpress.org) development.

* **Version**: 1.1-working
* **Latest Stable**: [v1.0](https://github.com/10up/varying-vagrant-vagrants/tree/v1.0)
* **Contributors**: [@jeremyfelt](http://github.com/jeremyfelt), [@carldanley](http://github.com/carldanley), [@ericmann](http://github.com/ericmann), [@lkwdwrd](http://github.com/lkwdwrd), [@TheLastCicada](http://github.com/TheLastCicada), [@tddewey](http://github.com/tddewey), [@johnpbloch](http://github.com/johnpbloch), [@kadamwhite](http://github.com/kadamwhite), [@scribu](http://github.com/scribu), [@danielbachhuber](http://github.com/danielbachhuber), [@tollmanz](http://github.com/tollmanz), [@mbijon](http://github.com/mbijon), [@markjaquith](http://github.com/markjaquith), [@curtismchale](http://github.com/curtismchale), [@Mamaduka](http://github.com/mamaduka), [@lgedeon](http://github.com/lgedeon), [@pmgarman](http://github.com/pmgarman), [@westonruter](http://github.com/westonruter), [@petemall](http://github.com/petemall), [@cmmarslender](http://github.com/cmmarslender), [@mintindeed](http://github.com/mintindeed), [@mboynes](http://github.com/mboynes), [@aaronjorbin](http://github.com/aaronjorbin), [@tobiasbg](http://github.com/tobiasbg), [@simonwheatley](http://github.com/simonwheatley), [@ocean90](http://github.com/ocean90), [@lvnilesh](http://github.com/lvnilesh), [@alexw23](http://github.com/alexw23), [@zamoose](https://github.com/zamoose), [@leewillis77](https://github.com/leewillis77), [@imichaeli](https://github.com/imichaeli), [@andrezrv](https://github.com/andrezrv), [@cadwell](https://github.com/cadwell), [@cfoellmann](https://github.com/cfoellmann), [@westi](https://github.com/westi), [@ryanduff](https://github.com/ryanduff), [@selinerdominik](https://github.com/selinerdominik), [@ericandrewlewis](https://github.com/ericandrewlewis), [@vDevices](https://github.com/vDevices)
* **Contributing**: Contributions are more than welcome. Please submit pull requests against the [master branch](https://github.com/10up/varying-vagrant-vagrants). Thanks!

## Overview

### The Purpose of Varying Vagrant Vagrants

The primary goal of Varying Vagrant Vagrants (VVV) is to provide an approachable way for developers to begin working in a development environment that matches a production environment as closely as possible.

The default server configuration provisioned by VVV is intended to match a common configuration for working with high traffic WordPress sites.

The default WordPress configurations provided by VVV are intended to create an environment ideal for developing themes and plugins as well as for contributing to WordPress core.

### How to Use Varying Vagrant Vagrants

#### VVV as a MAMP/XAMPP Replacement

VVV is ready to use as is. Download or clone VVV and then type `vagrant up` to automatically build a sandboxed Ubuntu server on your computer containing everything needed to contribute to WordPress core or develop a WordPress theme or plugin.

Multiple projects can be developed at once in the same environment.

* Use the `wordpress-develop` directory to participate in [WordPress core](http://core.trac.wordpress.org) development.
* Use `wp-content/themes` in either the `wordpress-default` or `wordpress-trunk` directories to develop multiple themes.
* Use `wp-content/plugins` in either the `wordpress-default` or `wordpress-trunk` directories to develop plugins.
* Take advantage of VVV's [auto site configuration](https://github.com/10up/varying-vagrant-vagrants/wiki/Auto-site-Setup) to provision additional instances of WordPress in `/srv/www/`.

#### VVV as a Scaffold

Entirely different server configurations can be created by modifying the files included with VVV and through the use of additional [Auto Site Setup](https://github.com/10up/varying-vagrant-vagrants/wiki/Auto-site-Setup) provisioning scripts.

It is not necessary to track the changes made to the main repository. Feel free to check this project out and then change everything to make it your own.

### The Future of Varying Vagrant Vagrants

Immediate goals for VVV include:

* Continue to work towards a stable state of software and configuration included in the default provisioning.
* Provide excellent and clear documentation throughout VVV to aid in both learning and scaffolding.

## Getting Started

### What is Vagrant?

[Vagrant](http://www.vagrantup.com) is a "tool for building and distributing development environments". It works with [virtualization](http://en.wikipedia.org/wiki/X86_virtualization) software such as [VirtualBox](https://www.virtualbox.org/) to provide a virtual machine that is sandboxed away from your local environment.

### The First Vagrant Up

1. Start with any operating system.
1. Install [VirtualBox 4.2.x](https://www.virtualbox.org/wiki/Download_Old_Builds_4_2) or [VirtualBox 4.3.4](https://www.virtualbox.org/wiki/Downloads)
    * Major portions of VirtualBox were rewritten for 4.3, and it's possible that there are still bugs to be shaken out. VVV is completely compatible with earlier versions of VirtualBox, so 4.2.18 or earlier would be just fine. Do note that Vagrant had specific issues with 4.2.16. Going as far back as 4.2.10 will likely be of no issue.
    * VVV itself leans in the 4.3.x direction in the master branch to stay ahead of the curve.
1. Install [Vagrant 1.4.0](http://www.vagrantup.com/downloads.html)
    * `vagrant` will now be available as a command in your terminal, try it out.
    * ***Note:*** If Vagrant is already installed, use `vagrant -v` to check the version. You may want to consider upgrading if a much older version is in use.
    * ***Note:*** If VirtualBox 4.3.x is installed, Vagrant 1.3.5 or later is required.
1. Install the [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plugin with `vagrant plugin install vagrant-hostsupdater`
    * Note: This step is not a requirement, though it does make the process of starting up a virtual machine nicer by automating the entries needed in your local machine's `hosts` file to access the provisioned VVV domains in your browser.
    * If you choose not to install this plugin, a manual entry should be added to your local `hosts` file that looks like this: `192.168.50.4  vvv.dev local.wordpress.dev local.wordpress-trunk.dev src.wordpress-develop.dev build.wordpress-develop.dev`
1. Clone or extract the Varying Vagrant Vagrants project into a local directory
    * `git clone git://github.com/10up/varying-vagrant-vagrants.git vagrant-local`
    * OR download and extract the repository master [zip file](https://github.com/10up/varying-vagrant-vagrants/archive/master.zip)
    * OR grab a [stable release](https://github.com/10up/varying-vagrant-vagrants/releases) if you'd like some extra comfort.
1. Change into the new directory with `cd vagrant-local`
1. Start the Vagrant environment with `vagrant up`
    * Be patient as the magic happens. This could take a while on the first run as your local machine downloads the required files.
    * Watch as the script ends, as an administrator or `su` ***password may be required*** to properly modify the hosts file on your local machine.
1. Visit any of the following default sites in your browser:
    * [http://local.wordpress.dev/](http://local.wordpress.dev/) for WordPress stable
    * [http://local.wordpress-trunk.dev/](http://local.wordpress-trunk.dev/) for WordPress trunk
    * [http://src.wordpress-develop.dev/](http://src.wordpress-develop.dev/) for trunk WordPress development files
    * [http://build.wordpress-develop.dev/](http://build.wordpress-develop.dev/) for the version of those development files built with Grunt
    * [http://vvv.dev/](http://vvv.dev/) for a default dashboard containing several useful tools

Fancy, yeah?

### What Did That Do?

The first time you run `vagrant up`, a packaged box containing a basic virtual machine is downloaded to your local machine and cached for future use. The file used by Varying Vagrant Vagrants contains an installation of Ubuntu 12.04 and is about 280MB.

After this box is downloaded, it begins to boot as a sandboxed virtual machine using VirtualBox. Once booted, it runs the provisioning script included with VVV. This initiates the download and installation of around 100MB of packages on the new virtual machine.

The time for all of this to happen depends a lot on the speed of your Internet connection. If you are on a fast cable connection, it will likely only take several minutes.

On future runs of `vagrant up`, the packaged box will be cached on your local machine and Vagrant will only need to apply the requested provisioning.

* ***Preferred:*** If the virtual machine has been powered off with `vagrant halt`, `vagrant up` will quickly power on the machine without provisioning.
* ***Rare:*** If you would like to reapply the provisioning scripts with `vagrant up --provision` or `vagrant provision`, some time will be taken to check for updates and packages that have not been installed.
* ***Very Rare:*** If the virtual machine has been destroyed with `vagrant destroy`, it will need to download the full 100MB of package data on the next `vagrant up`.

### Now What?

Now that you're up and running, start poking around and modifying things.

1. Access the server via the command line with `vagrant ssh` from your `vagrant-local` directory. You can do almost anything you would do with a standard Ubuntu installation on a full server.
    * **MS Windows users:** An SSH client is generally not distributed with Windows PCs by default. However, a terminal emulator such as [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) will provide access immediately. For detailed instructions on connecting with PuTTY, consult the [VVV Wiki](https://github.com/10up/varying-vagrant-vagrants/wiki/Connect-to-Your-Vagrant-Virtual-Machine-with-PuTTY).
1. Power off the box with `vagrant halt` and turn it back on with `vagrant up`.
1. Suspend the box's state in memory with `vagrant suspend` and bring it right back with `vagrant resume`.
1. Reapply provisioning to a running box with `vagrant provision`.
1. Destroy the box with `vagrant destroy`. Files added in the `www` directory will persist on the next `vagrant up`.
1. Start modifying and adding local files to fit your needs. Take a look at [Auto Site Setup](https://github.com/10up/varying-vagrant-vagrants/wiki/Auto-site-Setup) for tips on adding new projects.

#### Caveats

The network configuration picks an IP of 192.168.50.4. This works if you are *not* on the 192.168.50.x sub domain, it could cause conflicts on your existing network if you *are* on a 192.168.50.x sub domain already. You can configure any IP address in the `Vagrantfile` and it will be used on the next `vagrant up`

### Credentials and Such

All database usernames and passwords for WordPress installations included by default are `wp` and `wp`.

All WordPress admin usernames and passwords for WordPress installations included by default are `admin` and `password`.

#### WordPress Stable
* URL: `http://local.wordpress.dev`
* DB Name: `wordpress_default`

#### WordPress Trunk
* URL: `http://local.wordpress-trunk.dev`
* DB Name: `wordpress_trunk`

#### WordPress Develop
* /src URL: `http://src.wordpress-develop.dev`
* /build URL: `http://build.wordpress-develop.dev`
* DB Name: `wordpress_develop`
* DB Name: `wordpress_unit_tests`

#### MySQL Root
* User: `root`
* Pass: `root`
* See: [Connecting to MySQL](https://github.com/10up/varying-vagrant-vagrants/wiki/Connecting-to-MySQL) from your local machine

### What do you get?

A bunch of stuff!

1. [Ubuntu](http://www.ubuntu.com/) 12.04 LTS (Precise Pangolin)
1. [WordPress Develop](http://develop.svn.wordpress.org/trunk/)
1. [WordPress Stable](http://wordpress.org/)
1. [WordPress Trunk](http://core.svn.wordpress.org/trunk/)
1. [WP-CLI](http://wp-cli.org/)
1. [nginx](http://nginx.org/) 1.4.x
1. [mysql](http://www.mysql.com/) 5.5.x
1. [php-fpm](http://php-fpm.org/) 5.4.x
1. [memcached](http://memcached.org/) 1.4.13
1. PHP [memcache extension](http://pecl.php.net/package/memcache/3.0.8/) 3.0.8
1. PHP [xdebug extension](http://pecl.php.net/package/xdebug/2.2.3/) 2.2.3
1. PHP [imagick extension](http://pecl.php.net/package/imagick/3.1.0RC2/) 3.1.0RC2
1. [xdebug](http://xdebug.org/) 2.2.3
1. [PHPUnit](http://pear.phpunit.de/) 3.7.24
1. [ack-grep](http://beyondgrep.com/) 2.04
1. [git](http://git-scm.com/) 1.8.5
1. [subversion](http://subversion.apache.org/) 1.7.9
1. [ngrep](http://ngrep.sourceforge.net/usage.html)
1. [dos2unix](http://dos2unix.sourceforge.net/)
1. [Composer](https://github.com/composer/composer)
1. [phpMemcachedAdmin](https://code.google.com/p/phpmemcacheadmin/) 1.2.2 BETA
1. [phpMyAdmin](http://www.phpmyadmin.net/) 4.0.10 (multi-language)
1. [Webgrind](https://github.com/jokkedk/webgrind)
1. [NodeJs](http://nodejs.org/) Current Stable Version
1. [grunt-cli](https://github.com/gruntjs/grunt-cli) Current Stable Version

### Need Help?

* Let us have it! Don't hesitate to open a new issue on GitHub if you run into trouble or have any tips that we need to know.
* There is a [Mailing list](https://groups.google.com/forum/#!forum/wordpress-and-vagrant) for any topic related to WordPress and Vagrant that is a great place to get started.
* The [VVV Wiki](https://github.com/10up/varying-vagrant-vagrants/wiki) also contains documentation that may help.

### More Context

* [Varying Vagrant Vagrants](http://jeremyfelt.com/code/2012/12/11/varying-vagrant-vagrants/), where it all started.
* [Hi WordPress, Meet Vagrant](http://jeremyfelt.com/code/2013/04/08/hi-wordpress-meet-vagrant/), the blog post.
* [Hi WordPress, Meet Vagrant](http://wordpress.tv/2013/10/19/jeremy-felt-hi-wordpress-meet-vagrant/), the talk at WordCamp Vancouver.
