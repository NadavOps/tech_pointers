# Elasticsearch

### Table of Content
* [Elasticsearch APIs](#elasticsearch-apis)
  * [Indices APIs](#indices-apis)
  * [Nodes APIs](#nodes-apis)
  * [Shards APIs](#shards-apis)
  * [Snapshots Repositories and Restore](#snapshots-repositories-and-restore)
    * [Repositories APIs](#repositories-apis)
    * [Snapshot APIs](#snapshot-apis)
    * [Recovery APIs](#recovery-apis)
* [Elasticsearch Operations](#elasticsearch-operations)
  * [Rolling restart](#rolling-restart)
  * [Basic security configuration](#basic-security-configuration)
  * [Exclude nodes](#exclude-nodes)
* [Elasticsearch known issues](#elasticsearch-known-issues)
  * [Elasticsearch read only mode](#elasticsearch-read-only-mode)
* [Elasticsearch node roles by character](#elasticsearch-node-roles-by-character)
* [Links](#links)

## Elasticsearch APIs
Set the basics:
```
ELASTICSEARCH_FQDN=""
ELASTICSEARCH_USER=""
ELASTICSEARCH_PASS=""
```

Curl Requests with/ without authentication:
```
curl $ELASTICSEARCH_FQDN:9200
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200"
```

Basic APIs:
```
# Get basic cluster information
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200"

# See curl URI options
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat"

# cluster health
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/health?v"

# Current Master
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/master"
```

## Indices APIs
```
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/indices"
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/indices?v&h=index,store.size&bytes=gb"
curl -X POST -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/$es_index/_close?pretty"
curl -X DELETE -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/index_name?pretty" ->> delete an index
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_aliases" | jq -r 'keys[]' ->> list of all indices
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_aliases" | jq -r 'keys[]' | grep -v -e "^[.].*" ->> list indices with exclusion
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/<index_name>/_search" ->> return search hits that match the query
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" \
    "$ELASTICSEARCH_FQDN:9200/_index_template/*?filter_path=index_templates.name,index_templates.index_template.index_patterns,index_templates.index_template.data_stream"
    -->> list index templates
```

Create an index:
```
curl -XPUT -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/my-index-000001?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0
    }
  }
}
'
```

Get indices amount of primaries and replication factor:
```
for index in $(curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_aliases" | jq -r 'keys[]'); do 
  num_of_replicas=$(curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/$index/_settings" | jq -r '."'$index'".settings.index.number_of_replicas')
  num_of_primaries=$(curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/$index/_settings" | jq -r '."'$index'".settings.index.number_of_shards')
  echo "index: \"$index\" primaries: \"$num_of_primaries\" with replica factor of: \"$num_of_replicas\""
done
```

Bulk indices close v1:
```
ELASTICSEARCH_FQDN=
IGNORE_INDEX=
for es_index in $(curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/indices?v" | awk '{print $3}' | tail -n +2); do
  if [[ $es_index == "$IGNORE_INDEX" ]]; then
    continue
  fi
  curl -X POST -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/$es_index/_close?pretty"
done
```

Bulk indices close v2:
```
for es_index in $(curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_aliases" | jq -r 'keys[]' | grep -v -e "^[.].*"); do
  echo $es_index
  curl -X POST -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/$es_index/_close?pretty"
done
```

Bulk indices delete:
```
for es_index in $(curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_aliases" | jq -r 'keys[]' | grep -v -e "^[.].*"); do
  echo $es_index
  curl -X DELETE -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/$es_index?pretty"
done
```

## Nodes APIs
```
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/nodes?v"
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/nodes?v&h=node.role"
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/nodes?v=true&h=name,node*,heap*"
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_nodes/hot_threads"
  curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_nodes/hot_threads?threads=99999"
```

## Shards APIs
```
# Diagnose unallocated shards
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/shards?v=true&h=index,shard,prirep,state,node,unassigned.reason&s=state"
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cluster/allocation/explain?pretty"

ELASTICSEARCH_INDEX_NAME=""
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cluster/allocation/explain" \
  -H 'Content-Type: application/json' \
  -d'{"index": "'$ELASTICSEARCH_INDEX_NAME'", "shard": 75, "primary": true}'

# Allocate shard commands (if shards are unallocated they will not try to reallocate after 5 attempts)
curl -XPOST -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cluster/reroute?dry_run"
curl -XPOST -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cluster/reroute"

# This one was not tested -> should allow more shard shuffeling concurrently
curl -X PUT -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cluster/settings" \
  -H 'Content-Type: application/json' \
  -d'{"transient": {"cluster.routing.allocation.cluster_concurrent_rebalance": 2}}'
```

## Snapshots Repositories and Restore
## Repositories APIs
```
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/repositories?v"
```

## Snapshot APIs
```
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/snapshots/<repo_name>?v=true&s=id&pretty"

curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_snapshot/_status"
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_snapshot/<repo_name>"
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_snapshot/<repo_name>/_current"
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_snapshot/<repo_name>/<snapshot_name>"
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_snapshot/<repo_name>/<snapshot_name>/_status"

curl -XPUT -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_snapshot/<repo_name>?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "s3",
  "settings": {
    "bucket": "<bucket_name>",
    "client": "default",
    "base_path": "",
    "readonly": true
  }
}
'
```

## Recovery APIs
```
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/recovery"
```


## Elasticsearch Operations
## Rolling restart
* Allow shard allocation only for primaries:
```
curl -X PUT -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cluster/settings" \
  -H 'Content-Type: application/json' \
  -d'{"persistent": {"cluster.routing.allocation.enable": "primaries"}}'
```

* Flush:
```
curl -X POST -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_flush"
```

* Restart node and see that it joins with:
```
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cat/nodes?v"
```

* Allow all shard allocations:
```
curl -X PUT -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cluster/settings" \
  -H 'Content-Type: application/json' \
  -d'{"persistent": {"cluster.routing.allocation.enable": "all"}}'
```

Consider using the following:  
* Delay shard allocation on node leave:
```
curl -X PUT -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_all/_settings" \
  -H 'Content-Type: application/json' \
  -d'{"settings": {"index.unassigned.node_left.delayed_timeout": "10m"}}'
```

* Revert back shard allocation delay on node leave:
```
curl -X PUT -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_all/_settings" \
  -H 'Content-Type: application/json' \
  -d'{"settings": {"index.unassigned.node_left.delayed_timeout": "1m"}}'
```

## Basic security configuration

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

## Exclude nodes
```
curl -X PUT -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cluster/settings" \
  -H 'Content-Type: application/json' \
  -d'{"persistent": {"cluster.routing.allocation.exclude._name": ["node1", "node2"]}}'

curl -X PUT -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cluster/settings" \
  -H 'Content-Type: application/json' \
  -d'{"persistent": {"cluster.routing.allocation.exclude._name": ""}}'

curl -X GET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_cluster/settings" | jq .
```

## Elasticsearch known issues
## Elasticsearch read only mode
```
## Validate status
curl -XGET -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_all/_settings" | jq . | grep "read_only_allow_delete"

## Allow write again
curl -XPUT -s -u "$ELASTICSEARCH_USER":"$ELASTICSEARCH_PASS" "$ELASTICSEARCH_FQDN:9200/_all/_settings" \
  -H "Content-Type: application/json" \
  -d '{"index.blocks.read_only_allow_delete": null}'
```

## Elasticsearch node roles by character

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

## Links

* [Elastic node roles](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-nodes.html).
* [Elastic roles list](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/security-privileges.html).
* [Elastic fix common cluster issues](https://www.elastic.co/guide/en/elasticsearch//reference/master/fix-common-cluster-issues.html#high-jvm-memory-pressure).
* [Elastic Diagnose unassigned shards](https://www.elastic.co/guide/en/elasticsearch//reference/master/diagnose-unassigned-shards.html).
* [Elasticsearch cheat sheet by logzio](https://logz.io/blog/elasticsearch-cheat-sheet/).
* [Elasticsearch threadpool by opster](https://opster.com/guides/elasticsearch/glossary/elasticsearch-threadpool/).
* [Elasticsearch threadpool by opster2](https://opster.com/guides/elasticsearch/glossary/elasticsearch-queue/).
* [Shard Rebalancing tutorial](https://linuxhint.com/elasticsearch-shard-rebalancing-tutorial/)
* [ELK troubleshooting workshop](https://github.com/LisaHJung/Part-6-Troubleshooting-beginner-level-Elasticsearch-Errors/blob/main/README.md)
* Elasticsearch on K8s
  * https://coralogix.com/blog/running-elk-on-kubernetes-with-eck-part-2/
  * https://bluexp.netapp.com/blog/cvo-blg-elasticsearch-on-kubernetes-diy-vs.-elasticsearch-operator

* [Queue debugging in options by elastic developer in a forum](https://discuss.elastic.co/t/rejected-execution-queue-capacity-1000/89954).

* [Hot Threads](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-nodes-hot-threads.html).
  * [Hot Threads article explanation](https://cdmana.com/2020/11/20201112225049974p.html)

* [Slow log explanation](https://www.elastic.co/blog/advanced-tuning-finding-and-fixing-slow-elasticsearch-queries)

* [Security automation suggestion](https://github.com/elastic/helm-charts/blob/main/elasticsearch/examples/security/Makefile)

# not good for filtering yet
* [opster terraform bootstrap script](https://github.com/Opster/opensearch-terraform/blob/main/source/conf_setup.sh)

# Capacity Planing Links
## not good filtering yet
* [More links in answer](https://stackoverflow.com/questions/53214628/elasticsearch-how-does-sharding-affect-indexing-performance/53216210#53216210)
* [explanation and rally the benchmark tool](https://opster.com/guides/elasticsearch/capacity-planning/elasticsearch-number-of-shards/)
* [sizing shards](https://www.elastic.co/guide/en/elasticsearch/reference/current/size-your-shards.html)
* [sizing shards](https://www.elastic.co/blog/benchmarking-and-sizing-your-elasticsearch-cluster-for-logs-and-metrics)
* [optimize storage efficiency webinar](https://www.elastic.co/webinars/optimizing-storage-efficiency-in-elasticsearch)
* [design elasticsearch for perfection](https://thoughts.t37.net/designing-the-perfect-elasticsearch-cluster-the-almost-definitive-guide-e614eabc1a87)

More cores > slightly faster clock speed
increasing number of shards for read, less for write
try to evenly spread shards accros nodes
20 shards per 1GB of heap (600 in our case), true to elastic prio 8.3
