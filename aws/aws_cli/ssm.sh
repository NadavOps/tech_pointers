#!/bin/bash
aws ssm start-session \
    --document-name 'AWS-StartNonInteractiveCommand' \
    --parameters '{"command": ["sudo dnf install -y curl"]}' \
    --target your_instance_id