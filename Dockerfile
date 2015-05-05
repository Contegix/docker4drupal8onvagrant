# Docker Drupal Requirements
#
# VERSION       0.1
# DOCKER-VERSION        1.5
FROM    centos:latest
MAINTAINER Solomon S. Gifford <sgifford@blackmesh.com>

RUN yum -y update
RUN yum -y install httpd

RUN yum -y install mariadb-server mariadb
RUN chown -R mysql:mysql /var/lib/mysql
RUN mysql_install_db --user=mysql > /dev/null
RUN echo "UPDATE mysql.user SET Password=PASSWORD('root'), Host='%' WHERE User='root' and Host='localhost';" | /usr/libexec/mysqld --bootstrap
RUN chown -R mysql:mysql /var/lib/mysql

RUN yum -y install php php-mysql php-gd php-mbstring php-xml
RUN yum -y install php-pear php-devel httpd-devel pcre-devel gcc make
RUN pecl install apc
RUN echo "extension=apc.so" > /etc/php.d/apc.ini
RUN yum -y install memcached php-pecl-memcache
RUN yum -y install tar wget git httpd pwgen python-setuptools vim


# Still need drush
RUN wget --quiet -O - http://ftp.drupal.org/files/projects/drush-7.x-4.5.tar.gz | tar -zxf - -C /usr/local/share
RUN ln -s /usr/local/share/drush/drush /usr/local/bin/drush

# Make mysql listen on the outside
RUN sed -i "s/^bind-address/#bind-address/" /etc/my.cnf
ADD supervisord /etc/supervisord.conf

RUN easy_install supervisor

# Ready for Drupal
RUN rm -rf /var/www/html 

EXPOSE 80 3306
CMD ["/usr/bin/supervisord"]
