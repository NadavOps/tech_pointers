# Atlas

### Table of Content
* [Commands](#commands)
* [Metrics](#metrics)
* [Links](#links)

## Commands
```bash
# create network peering container + validation in AWS us-east-1
public_key=""
private_key=""
atlasCidrBlock="cidr/mask"
ATLAS_PROJECT_NAME="Your_Project_Name"
ATLAS_PROJECT_ID=$(atlas projects list | grep -e ""$ATLAS_PROJECT_NAME"$" | awk '{print $1}')

atlas projects create "$ATLAS_PROJECT_NAME"
atlas projects delete "$ATLAS_PROJECT_ID"
atlas networking containers list --projectId "$ATLAS_PROJECT_ID"

curl --user "$public_key:$private_key" --digest \
     --header "Accept: application/json" \
     --header "Content-Type: application/json" \
     --request POST "https://cloud.mongodb.com/api/atlas/v1.0/groups/$ATLAS_PROJECT_ID/containers?pretty=true" \
     --data '
       {
         "atlasCidrBlock" : "'$atlasCidrBlock'",
         "providerName" : "AWS",
         "regionName" : "US_EAST_1"
       }'

curl -s --user "$public_key:$private_key" --digest \
     --header "Accept: application/json" \
     --request GET "https://cloud.mongodb.com/api/atlas/v1.0/groups/$ATLAS_PROJECT_ID/containers" | jq .

curl -s --user "$public_key:$private_key" --digest \
     --header "Accept: application/json" \
     --request GET "https://cloud.mongodb.com/api/atlas/v1.0/groups/$ATLAS_PROJECT_ID/containers/all" | jq .
```

```
dig SRV _mongodb._tcp.hostname
mongosh "mongodb+srv://user:pass@hostname/myFirstDatabase" --apiVersion 1
```

## Metrics
* Mongo less CPU intesive, More RAM intesive
* Mongo uses WiredTiger Storage engine, which uses cache of 50% * (TotalRAM - 1GB), or 256MB which explains the high mem usage
* Using the minimum allowed storage because its free + the maximum storage increase the oplog window, has 5% of the storage is the default dedicated for it.
     * Relication oplog window is the amount of time a replica can recover from failure without needing to full sync, sync all the data from scratch from the primary
* In AWS deployments read and writes consume from the pool of IOPS combined.
* disk latency should be less than 100s (rule of thumb)
* cluster tier scaling, verify 1H to scale, 24H to down scale.
* each connection requires around 1MB memory.

## Indices
* rule of tump, up to 20 indices per collection
* ESR -> equality (match), Sort(), Range (GT, LT), it is better to form queries from E to S to R, when indices are in place, because match will narrow results, sort should be before range to avoid in memory sort (we already have sorted data because of index), and now we should search for the range.

## Query in Compass Ui
{ "field.nestedfield": {$in:["item1","item2","item3"]}}

## Questions
* How to identify unused indices?
* How to optimize queries?
* how to move to a smaller instance?


## Links

* [mongodb analyzer](https://www.mongodb.com/docs/mongodb-analyzer/current/)
* [Key hole](https://www.mongodb.com/blog/post/peek-at-your-mongodb-clusters-like-a-pro-with-keyhole-part-1)
