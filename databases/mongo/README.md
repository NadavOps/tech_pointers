# Atlas

### Table of Content
* [Commands](#commands)
* [Scripts](#scripts)

## Commands
```bash
mongo_user="mongo"
mongo_pass="pass"
connection_string="127.0.0.1:27017"

mongosh mongodb://$mongo_user:$mongo_pass@$connection_string --quiet --eval "db.adminCommand('ping')"
mongosh mongodb://$mongo_user:$mongo_pass@$connection_string --quiet --eval 'rs.initiate()'
mongosh mongodb://$mongo_user:$mongo_pass@$connection_string --quiet --eval 'rs.status()'
mongosh mongodb://$mongo_user:$mongo_pass@$connection_string --quiet --eval 'rs.status().code'
mongosh mongodb://$mongo_user:$mongo_pass@$connection_string --quiet --eval 'rs.conf()'
mongosh mongodb://$mongo_user:$mongo_pass@$connection_string --quiet --eval 'rs.conf().members[0].host'

mongosh mongodb://$mongo_user:$mongo_pass@$connection_string --quiet --eval 'rs.initiate({ "_id": "rs0", version: 1, members: [{ _id: 0, host : "'$connection_string'" }]})'

mongosh mongodb://$mongo_user:$mongo_pass@$connection_string --quiet --eval 'rs.reconfig({ "_id": "rs0", "members": [{ "_id": 0, "host": "'$$connection_string'" }] }, { force: true })'
```

## Scripts
```bash
# Unsuccessful attempt to initialize a standalone replicaset and set its host name as an external name
# Need to check how did atlas/ bitnami did it
#!/bin/bash
mongo_user="mongo"
mongo_pass="pass"
mongo_ip="127.0.0.1"
mongo_port="27017"
external_connection_string="fqdn.example.com:27017"
counter=0

while true; do
     mongosh mongodb://$mongo_user:$mongo_pass@$mongo_ip:$mongo_port --quiet --eval 'rs.status().code'
     rs_status_code="$?"
     if [[ "$rs_status_code" == "0" ]]; then
          echo "INFO: Replica set is initiated"
          break
     fi
     echo "WARN: not yet initiated"
     mongosh mongodb://$mongo_user:$mongo_pass@$mongo_ip:$mongo_port --quiet --eval 'rs.initiate()'
     sleep 1
     if [ $counter -eq 20 ]; then
          echo "ERROR: Initialization have yet to succeed after more than 20 seconds"
          exit 1
     fi
done

while true; do
     host=$(mongosh mongodb://$mongo_user:$mongo_pass@$mongo_ip:$mongo_port --quiet --eval 'rs.conf().members[0].host')
     if [[ "$host" == "$external_connection_string" ]]; then
          echo "INFO: mongo host is now $host"
          break
     fi
     echo "WARN: mongo host is $host and not $external_connection_string"
     mongosh mongodb://$mongo_user:$mongo_pass@$mongo_ip --quiet --eval 'rs.reconfig({ "_id": "rs0", "members": [{ "_id": 0, "host": "'$external_connection_string'" }] }, { force: true })'
     sleep 1
     if [ $counter -eq 20 ]; then
          echo "ERROR: Setting hostname have yet to succeed after more than 20 seconds"
          exit 1
     fi
done

echo "INFO: configuration done"
```
