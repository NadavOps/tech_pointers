# Postgress

### Table of Content
* [Commands](#clickhouse)
  * [Client](#client)
  * [SQL](#sql)
* [Links](#links)

## Mac install
```bash
# The below will install postgress utilities /usr/local/opt/libpq/bin but will not add it to path
brew install libpq
```

## Commands
## Client
```bash
postgress_host="url"
postgress_user="user_name"
postgress_pass="password_string"
postgress_db_name="db_name"

# connect
psql -h "$postgress_host" -p 5432 -U "$postgress_user" -d "$postgress_db_name"
PGPASSWORD="$postgress_pass" psql -h "$postgress_host" -p 5432 -U "$postgress_user"

# create user
PGPASSWORD="$postgress_pass" /usr/local/opt/libpq/bin/createuser -h "$postgress_host" -p 5432 -U "$postgress_user" "$postgress_db_name"
createuser --username=ADMIN_USER_NAME --host=your_host --port=your_port --createdb --createrole --login --pwprompt "$postgress_user"

# create db
PGPASSWORD="$postgress_pass" /usr/local/opt/libpq/bin/createdb -h "$postgress_host" -p 5432 -U "$postgress_user" "$postgress_db_name"
createdb --username=ADMIN_USER_NAME --host=your_host --port=your_port --owner="$postgress_user" --encoding=UTF8 --template=template0 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8 "$postgress_db_name"

# take dump
PGPASSWORD="$postgress_pass" pg_dump -h "$postgress_host" -p 5432 -U "$postgress_user" -d "$postgress_db_name" -F c -f /tmp/dump.dump

# restore from dump
PGPASSWORD="$postgress_pass" pg_restore -h "$postgress_host" -p 5432 -U "$postgress_user" -d "$postgress_db_name" -e /tmp/dump.dump

## Export database
bash
pg_dump -h "$postgress_host" -p 5432 -U "$postgress_user" -d "$postgress_db_name" -F c -f tmp/dump.dump
pg_dump -h "$postgress_host" -p 5432 -U "$postgress_user" -d "$postgress_db_name" > tmp/dump.dump

## Import database
bash
pg_restore -h "$postgress_host" -p 5432 -U "$postgress_user" -d "$postgress_db_name" -C tmp/dump.dump
psql --set ON_ERROR_STOP=on -h "$postgress_host" -p 5432 -U "$postgress_user" -d "$postgress_db_name" < tmp/dump.dump
```



## SQL
```bash
# Show databases
\l

# Basic commands
DROP DATABASE user_name;
DROP USER user_name;

SELECT * FROM pg_user;
SELECT * FROM pg_database;
SELECT * FROM information_schema.role_table_grants WHERE grantee = 'user_name';

# create user + db permissions
CREATE USER user_name WITH LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE user_name WITH PASSWORD 'password_string';
CREATE DATABASE db_name
       ENCODING = 'UTF8'
       LC_COLLATE = 'en_US.UTF-8'
       LC_CTYPE = 'en_US.UTF-8';
ALTER DATABASE db_name OWNER TO user_name;

#
SELECT datname, pg_encoding_to_char(encoding), datcollate, datctype,
FROM pg_database
WHERE datname = 'db_name';

#
SELECT pg_size_pretty(pg_database_size('db_name')) AS size;


### Wal and replication
SELECT * FROM pg_stat_replication;
SELECT * FROM pg_replication_slots;
SELECT slot_name, active, slot_type, database, plugin FROM pg_replication_slots;
SELECT pg_drop_replication_slot('slot_name');
```

## Links
* [Mac installation](https://stackoverflow.com/questions/44654216/correct-way-to-install-psql-without-full-postgres-on-macos).

https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.Roles.html
https://aws.amazon.com/blogs/database/managing-postgresql-users-and-roles/
https://itecnote.com/tecnote/sql-error-must-be-member-of-role-when-creating-schema-in-postgresql/
