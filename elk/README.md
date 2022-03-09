ELK
===========

<!--ts-->
  * [Elasticsearch curl requests](#elasticsearch-curl-requests)
  * [Elasticsearch security](#elasticsearch-security)
  * [Elasticsearch node roles by character](#elasticsearch-node-roles-by-character)
  * [Elasticsearch snapshot status](#elasticsearch-snapshot-status)
  * [Links](#links)
<!--te-->


Elasticsearch curl requests
====
```
# Set ENV
ELASTICSEARCH_FQDN=""

# Get basic cluster information
curl $ELASTICSEARCH_FQDN:9200

# See curl URI options
curl $ELASTICSEARCH_FQDN:9200/_cat

# Get nodes information
curl "$ELASTICSEARCH_FQDN:9200/_cat/nodes?v=true&pretty"
curl "$ELASTICSEARCH_FQDN:9200/_cat/nodes?v&h=node.role"

# curl GET with authentication
ELASTIC_USERNAME=
ELASTIC_USERNAME_PASS=
curl --user $ELASTIC_USERNAME:$ELASTIC_USERNAME_PASS -XGET "$ELASTICSEARCH_FQDN:9200/_cat/nodes?v=true&pretty"

# cluster health
curl "$ELASTICSEARCH_FQDN:9200/_cat/health?v"

# indices
curl $ELASTICSEARCH_FQDN:9200/_cat/indices
curl -X DELETE "$ELASTICSEARCH_FQDN:9200/index_name?pretty"
```


Elasticsearch security
===
```
# Elasticsearch certs
./bin/elasticsearch-certutil ca
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12

# Elasticsearch built in user creation
cd /usr/share/elasticsearch # different distributions differnt paths -> set | grep -i elastic
./bin/elasticsearch-setup-passwords interactive # or ./bin/elasticsearch-setup-passwords auto

# Kibana
echo 'elasticsearch.username: "kibana_system"' >> kibana.yml
./bin/kibana-keystore create
./bin/kibana-keystore add elasticsearch.password
```


Elasticsearch node roles by character
====
```
c - cold node
d - data node
f - frozen node
h - hot node
i - ingest node
l - machine learning node
m - master eligeble node
r - remote cluster node
s - content node
t - transform node
v - voting only node
w - warm node
"-" - coordinating node only
```


Elasticsearch snapshot status
===
```
_snapshot/_status
_snapshot/<repo_name>
_snapshot/<repo_name>/_current
_snapshot/<repo_name>/<snapshot_name>
_snapshot/<repo_name>/<snapshot_name>/_status
```

Elasticsearch bulk index close
===
```
ELASTICSEARCH_FQDN=
IGNORE_INDEX=
for es_index in $(curl -s "$ELASTICSEARCH_FQDN:9200/_cat/indices?v" | awk '{print $3}' | tail -n +2); do
  if [[ $es_index == "$IGNORE_INDEX" ]]; then
    continue
  fi
  curl -X POST "$ELASTICSEARCH_FQDN:9200/$es_index/_close?pretty"
done
```


Links
====
* [Elastic node roles](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-nodes.html).
* [Elastic roles list](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/security-privileges.html).
* [asd](https://www.codecademy.com/learn/learn-git)
