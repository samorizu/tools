#!/usr/bin
#apache2 statup script

#stopping apache server
service apache2 stop

#making a backup of the fresh configs
mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
mv /etc/apache2/ports.conf /etc/apache2/ports.conf.bak

#moving premade config to apache dir
mv `pwd`/conf /etc/apache2/apache2.conf

#making the new ports.conf file
echo "NameVirtualHost *:80" >> /etc/apache2/ports.conf
echo "Listen 80" >> /etc/apache2/ports.conf
echo "<IfModule mod_ssl.c>" >> /etc/apache2/ports.conf
echo "</IfModule>" >> /etc/apache2/ports.conf
echo "<IfModule mod_gnutls.c>" >> /etc/apache2/ports.conf
echo "    Listen 443" >> /etc/apache2/ports.conf
echo "</IfModule>" >> /etc/apache2/ports.conf

#restarting service
service apache2 restart

#MOD SECURITY SECTOIN
#installing dependencies
sudo apt-get install libxml2 libxml2-dev libxml2-utils -y
sudo apt-get install libaprutil1 libaprutil1-dev -y

#installing mod security
sudo apt-get install libapache-mod-security -y

#moving in my config file
mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf.bak
mv `pwd`/mod /etc/modsecurity/modsecurity.conf

#installing OWASP Security measures
wget -O SpiderLabs-owasp-modsecurity-crs.tar.gz https://github.com/SpiderLabs/owasp-modsecurity-crs/tarball/master
tar -zxvf SpiderLabs-owasp-modsecurity-crs.tar.gz
cp -R SpiderLabs-owasp-modsecurity-crs-*/* /etc/modsecurity/
rm SpiderLabs-owasp-modsecurity-crs.tar.gz
rm -R SpiderLabs-owasp-modsecurity-crs-*
sudo mv /etc/modsecurity/modsecurity_crs_10_setup.conf.example /etc/modsecurity/modsecurity_crs_10_setup.conf

#creating links
cd /etc/modsecurity/base_rules
for f in * ; do sudo ln -s /etc/modsecurity/base_rules/$f /etc/modsecurity/activated_rules/$f ; done
cd /etc/modsecurity/optional_rules
for f in * ; do sudo ln -s /etc/modsecurity/optional_rules/$f /etc/modsecurity/activated_rules/$f ; done 

#making the conf file avalible
rm /etc/apache2/mods-available/mod-security.conf
echo "<IfModule security2_module>" >> /etc/apache2/mods-available/mod-security.conf
echo "        SecDataDir /var/cache/modsecurity" >> /etc/apache2/mods-available/mod-security.conf
echo "        Include \"/etc/modsecurity/activated_rules/*.conf\"" >> /etc/apache2/mods-available/mod-security.conf
echo "        Include \"/etc/modsecurity/*.conf\"" >> /etc/apache2/mods-available/mod-security.conf
echo "</IfModule>" >> /etc/apache2/mods-available/mod-security.conf

#restarting apache to enable
service apache2 restart
