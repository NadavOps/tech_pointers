#!/bin/bash
for some_file in *; do
    if echo $some_file | grep -q -e ".json$"; then
        python3 -m json.tool $some_file > prettify/$some_file
    fi
done