#!/bin/bash

aws cloudtrail lookup-events \
--lookup-attributes AttributeKey=EventName,AttributeValue=UpdateTable \
--start-time "2025-01-23T05:26:03Z" \
--end-time "2025-01-23T14:00:00Z" \
--query 'Events[]'
