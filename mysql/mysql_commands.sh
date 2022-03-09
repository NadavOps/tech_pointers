MYSQL_HOST=host
MYSQL_HOST_PORT=3306
MYSQL_USER=user
MYSQL_PASS=pass

connect to host:
mysql -h $MYSQL_HOST -P $MYSQL_HOST_PORT -u $MYSQL_USER -p $MYSQL_PASS

Search a user:
SELECT User, Host FROM mysql.user;
SELECT User, Host FROM mysql.user WHERE User Like 'user_name';

Show prievilleges:
SHOW GRANTS FOR 'user_name';

CREATE USER 'delete_me_user_asap'@'%' IDENTIFIED BY 'delete_me_user_asap1234%$!@';
grant select on information_schema.* to 'delete_me_user_asap'@'%' identified by 'delete_me_user_asap1234%$!@';
GRANT SELECT ON *.* TO 'delete_me_user_asap'@'%';
GRANT SELECT, PROCESS, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT, SHOW VIEW ON *.* TO 'delete_me_user_asap'@'%';

DROP USER 'delete_me_user_asap'@'%';

ALTER USER 'delete_me_user_asap'@'%' IDENTIFIED BY 'delete_me_user_asap1234_new_pass';
FLUSH PRIVILEGES;

Process list:
SHOW FULL PROCESSLIST
SELECT * FROM information_schema.processlist WHERE `USER` LIKE 'event_scheduler';

Global variables:
SHOW GLOBAL VARIABLES LIKE 'event%';
call mysql.rds_show_configuration;
call mysql.rds_set_configuration('binlog retention hours', 24);