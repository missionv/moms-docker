FROM ubuntu:14.04
MAINTAINER John Jennings <john@missionv.ie>
RUN apt-get -qq update
RUN apt-get -qqy install mono-complete curl git apache2 libapache2-mod-php5 mysql-server php5-mysql supervisor
RUN curl -L  http://opensimulator.org/dist/opensim-0.7.6.1.tar.gz | tar -xz
CMD cd /opensim-0.7.6.1/bin && mono OpenSim.exe
 

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD import_sql.sh /import_sql.sh
ADD create_db.sh /create_db.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite


# Configure /app folder with sample app
RUN git clone https://github.com/fermayo/hello-world-lamp.git /app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306 9000 9001 9002 9003 8000 8001 8002 8003 8004
CMD ["/run.sh"]
