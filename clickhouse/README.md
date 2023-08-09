# Clickhouse

### Table of Content
* [Commands](#clickhouse)
* [Links](#links)

## Commands
```
# show table structure
SHOW CREATE TABLE your_database_name.your_table_name;

# Get big tables
SELECT table,
    formatReadableSize(sum(bytes)) as size,
    min(min_date) as min_date,
    max(max_date) as max_date
    FROM system.parts
    WHERE active
    GROUP BY table;

# Mutations (processes?)
select * from system.mutations where not is_done;
KILL MUTATION WHERE mutation_id = 'youre_mutation_name.txt'

# Partitions
select distinct partition from system.parts where database ='your_database_name' and active;
ALTER TABLE your_database_name.your_table_name DROP PARTITION 'your_partition_name_from_previous_command';

# Change TTL example
ALTER TABLE your_database_name.your_table_name MODIFY TTL toStartOfWeek(time + toIntervalWeek(2));

# Delete data from table, while maintaining table and structure
TRUNCATE your_database_name.your_table_name;
```

## Links
* [Alinity- managed clickhouse](https://kb.altinity.com/altinity-kb-queries-and-syntax/ttl/modify-ttl/).
