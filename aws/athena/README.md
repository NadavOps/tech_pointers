# Athena

# Table of Content
* [Commands](#commands)
* [Links](#links)

# Commands
```
CREATE DATABASE IF NOT EXISTS database_name;
DROP TABLE IF EXISTS table_name;
DROP DATABASE IF EXISTS database_name;
```

# Examples
```
## Create table to analyze Transit VPC flow logs
CREATE EXTERNAL TABLE IF NOT EXISTS `database_name`.`transitvpclogs` (
  `version` int, 
  `resource_type` string, 
  `account_id` string, 
  `tgw_id` string, 
  `tgw_attachment_id` string, 
  `tgw_src_vpc_account_id` string, 
  `tgw_dst_vpc_account_id` string, 
  `tgw_src_vpc_id` string, 
  `tgw_dst_vpc_id` string, 
  `tgw_src_subnet_id` string, 
  `tgw_dst_subnet_id` string, 
  `tgw_src_eni` string, 
  `tgw_dst_eni` string, 
  `tgw_src_az_id` string, 
  `tgw_dst_az_id` string, 
  `tgw_pair_attachment_id` string, 
  `srcaddr` string, 
  `dstaddr` string, 
  `srcpor` int, 
  `dstport` int, 
  `protocol` bigint, 
  `packet` bigint, 
  `bytes` bigint, 
  `start` bigint, 
  `end` bigint, 
  `log_status` string, 
  `type` string, 
  `packets_lost_no_route` bigint, 
  `packets_lost_blackhole` bigint, 
  `packets_lost_mtu_exceeded` bigint, 
  `packets_lost_ttl_expired` bigint, 
  `tcp_flags` int, 
  `region` string, 
  `flow_direction` string, 
  `pkt_src_aws_service` string, 
  `pkt_dst_aws_service` string)
PARTITIONED BY (`date` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ' ' 
LOCATION
  's3://bucket_name/AWSLogs/aws_account_id/vpcflowlogs/aws_region/'
TBLPROPERTIES (
  'skip.header.line.count'='1',
  'projection.enabled'='true', 
  'projection.date.format'='yyyy/MM/dd', 
  'projection.date.interval'='1', 
  'projection.date.interval.unit'='DAYS', 
  'projection.date.range'='2023/05/01,NOW', 
  'projection.date.type'='date', 
  'storage.location.template'='s3://bucket_name/AWSLogs/aws_account_id/vpcflowlogs/aws_region/${date}')

## Query Top 10 source to destination bytes transfer
SELECT MIN(start), srcaddr, dstaddr, SUM(bytes) AS total_bytes
FROM transitvpclogs
GROUP BY srcaddr, dstaddr
ORDER BY total_bytes DESC
LIMIT 10;
```


# Links

* [DDL reference](https://docs.aws.amazon.com/athena/latest/ug/ddl-reference.html).
* [Amazon Flow Logs]
    * [Querying Amazon VPC flow logs](https://docs.aws.amazon.com/athena/latest/ug/vpc-flow-logs.html)
    * [Analyze VPC flow logs](https://repost.aws/knowledge-center/athena-analyze-vpc-flow-logs).
    * [Transit flow logs](https://sjramblings.io/unleashing-the-power-of-aws-athena-on-transit-gateway-flow-logs) # wasn't using it in the end for the athena configuration
