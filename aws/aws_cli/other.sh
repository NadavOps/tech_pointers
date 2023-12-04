#!/bin/bash
aws ec2 describe-instances \
  --query 'Reservations[].Instances[?KeyName && starts_with(KeyName, `key_name_prefix`)][].{InstanceId:InstanceId, State:State.Name}' \
  --output table