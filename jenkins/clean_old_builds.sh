#!/bin/bash
jenkins_jobs_path="/var/lib/jenkins/jobs"
dry_run="true" ## Change here to actually delete
for jenkins_job in $jenkins_jobs_path/*/; do
    build_dir="$jenkins_job/builds"
    if [[ ! -d "$build_dir" ]]; then
        echo "$jenkins_job did not had builds folder in it, continue"
        continue
    fi
    number_of_builds=$(find "$build_dir" -maxdepth 1 -type d -mtime +30 -regex '.*[0-9]$' | wc -l)
    if [[ $number_of_builds -le 15 ]]; then
        # echo "$build_dir has low amount of builds (under 15)"
        continue
    fi
    echo "$build_dir  --->  $number_of_builds"
    if [[ "$dry_run" == "true" ]]; then
        find "$build_dir" -maxdepth 1 -type d -mtime +30 -regex '.*[0-9]$' -exec echo {} \;
    else
        find "$build_dir" -maxdepth 1 -type d -mtime +30 -regex '.*[0-9]$' -exec sudo rm -rf {} \;
    fi
done
