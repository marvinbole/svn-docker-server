FROM ubuntu:bionic-20181112

RUN mkdir -p /var/svn/repos
RUN apt-get update && apt-get install -y systemd netcat curl net-tools inetutils-ping bash vim
RUN apt-get install -y apache2 apache2-utils subversion libapache2-mod-svn subversion-tools libsvn-dev

RUN systemctl enable apache2.service
RUN a2enmod dav && a2enmod dav_svn

RUN htpasswd -cb /etc/subversion/passwd svn svn123 && svnadmin create /var/svn/repos/test && chown -R www-data:www-data /var/svn/repos


ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

COPY http-svn.conf /var/svn/
RUN cat /var/svn/http-svn.conf >> /etc/apache2/mods-enabled/dav_svn.conf

EXPOSE 80 443 3960

ENTRYPOINT [ "/usr/sbin/apachectl" ]
CMD ["-D", "FOREGROUND"]