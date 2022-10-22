MYSQL_HOST=host
MYSQL_HOST_PORT=3306
MYSQL_USER=user_name
MYSQL_PASS=some_made_up_password

# Connect to host:
mysql -h $MYSQL_HOST -P $MYSQL_HOST_PORT -u $MYSQL_USER -p$MYSQL_PASS

# Search a user:
SELECT User, Host FROM mysql.user;
SELECT User, Host FROM mysql.user WHERE User Like 'user_name';

# User basics:
CREATE USER 'user_name'@'%' IDENTIFIED BY 'some_made_up_password';
ALTER USER 'user_name'@'%' IDENTIFIED BY 'some_other_password';
DROP USER 'user_name'@'%';

# Show prievilleges:
SHOW GRANTS FOR 'user_name';

# Grant prievilleges:
GRANT SELECT ON schema_name.* TO 'user_name'@'%'; # <-- Read Only
GRANT SELECT ON schema_name.* TO 'user_name'@'%' IDENTIFIED BY 'some_made_up_password'; # <-- Read Only + password
GRANT SELECT,INSERT,UPDATE,DELETE,EXECUTE,SHOW VIEW,CREATE,
    ALTER,REFERENCES,INDEX,CREATE VIEW,CREATE ROUTINE,ALTER ROUTINE,
    EVENT,DROP,TRIGGER,CREATE TEMPORARY TABLES,LOCK TABLES ON schema_name.* TO 'user_name'@'%'; # <-- Write User
GRANT SELECT, PROCESS, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT, SHOW VIEW ON *.* TO 'user_name'@'%'; # <-- replication user

FLUSH PRIVILEGES;

# Process list:
SHOW FULL PROCESSLIST;
SELECT * FROM information_schema.processlist WHERE `USER` LIKE 'event_scheduler';

# Global variables:
SHOW GLOBAL VARIABLES LIKE 'event%';
call mysql.rds_show_configuration;
call mysql.rds_set_configuration('binlog retention hours', 24);

# Triggers:
SHOW TRIGGERS in schema_name;
DROP TRIGGER schema_name.trigger_name;

# Interactive mysql commands from shell:
mysql -h $MYSQL_HOST -P $MYSQL_HOST_PORT -u $MYSQL_USER -p$MYSQL_PASS -e "command"
mysql -h $MYSQL_HOST -P $MYSQL_HOST_PORT -u $MYSQL_USER -p$MYSQL_PASS < sql_script_file.sql
mysql -h $MYSQL_HOST -P $MYSQL_HOST_PORT -u $MYSQL_USER -p$MYSQL_PASS < sql_script_file.sql > csv_file.csv

# Assumption1 -> show locking processes?
show variables like 'innodb_lock_wait_timeout';
SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST WHERE COMMAND = "Sleep" AND TIME > 60;
