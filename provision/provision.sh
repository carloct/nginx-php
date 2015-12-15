#!/bin/bash
# ------------------------------------------------------------------------------
# Provisioning script for the docker-laravel web server stack
# ------------------------------------------------------------------------------

export DEBIAN_FRONTEND=noninteractive

apt-get update

# Update System Packages
apt-get -y upgrade

echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
locale-gen en_US.UTF-8


# Install Some PPAs

apt-get install -y software-properties-common curl

apt-add-repository ppa:nginx/stable -y
apt-add-repository ppa:rwky/redis -y
apt-add-repository ppa:ondrej/php-7.0 -y

# Update Package Lists

apt-get update

sed -i -e "s/exit\s*101/exit 0/g" /usr/sbin/policy-rc.d

# ------------------------------------------------------------------------------
# Install Some Basic Packages
# ------------------------------------------------------------------------------
# Install python (required for Supervisor)
apt-get -y install python software-properties-common nano git libmcrypt4 libpcre3-dev \
whois vim

# ------------------------------------------------------------------------------
# Supervisor
# ------------------------------------------------------------------------------

mkdir -p /etc/supervisord/
mkdir /var/log/supervisord

# copy all conf files
cp /provision/conf/supervisor.conf /etc/supervisord.conf
cp /provision/service/* /etc/supervisord/

curl https://bootstrap.pypa.io/ez_setup.py -o - | python

easy_install supervisor

# ------------------------------------------------------------------------------
# SSH
# ------------------------------------------------------------------------------

apt-get -y install openssh-server
mkdir /var/run/sshd

# ------------------------------------------------------------------------------
# cron
# ------------------------------------------------------------------------------

apt-get -y install cron

# Set My Timezone
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

# ------------------------------------------------------------------------------
# NGINX web server
# ------------------------------------------------------------------------------

# install nginx
apt-get install -y --force-yes nginx php7.0-fpm

# copy a development-only default site configuration
cp /provision/conf/nginx-development /etc/nginx/sites-available/default

# disable 'daemonize' in nginx (because we use supervisor instead)
echo "daemon off;" >> /etc/nginx/nginx.conf

# ------------------------------------------------------------------------------
# PHP7
# ------------------------------------------------------------------------------

apt-get install -y --force-yes php7.0-cli php7.0-dev \
php-sqlite3 php-gd \
php-curl \
php-imap php-mysql

# copy FPM and CLI PHP configurations
cp /provision/conf/php.fpm.ini /etc/php/7.0/fpm/php.ini
cp /provision/conf/php.cli.ini /etc/php/7.0/cli/php.ini

# disable 'daemonize' in php5-fpm (because we use supervisor instead)
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf


# ------------------------------------------------------------------------------
# Composer PHP dependency manager
# ------------------------------------------------------------------------------

# install the latest version of composer
php -r "readfile('https://getcomposer.org/installer');" | php
mv composer.phar /usr/local/bin/composer

# ------------------------------------------------------------------------------
# Clean up
# ------------------------------------------------------------------------------
rm -rf /provision
