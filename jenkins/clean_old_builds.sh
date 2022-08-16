#!/bin/bash
script_jenkins_path="/var/lib/jenkins/jobs"
for project_dir in $script_jenkins_path/*/; do
    build_dir="$project_dir/builds"
    number_of_builds=$(find "$build_dir" -maxdepth 1 -type d -mtime +30 -regex '.*[0-9]$' | wc -l)
    if [[ $number_of_builds -gt 15 ]]; then
        echo "$build_dir  --->  $number_of_builds"
        find "$build_dir" -maxdepth 1 -type d -mtime +30 -regex '.*[0-9]$' -exec echo {} \;
        # find "$build_dir" -maxdepth 1 -type d -mtime +30 -regex '.*[0-9]$' -exec sudo rm -rf {} \;
    fi
done
