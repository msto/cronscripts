#!/bin/bash
#
# du.sh
# Copyright (C) 2015 Matthew Stone <mstone5@mgh.harvard.edu>
#
# Distributed under terms of the MIT license.
#
PATH=/bin:/usr/bin

dir=$1

# Initialize logging if necessary
if [ ! -d "${dir}/du_logs" ]; then
    mkdir ${dir}/du_logs
    mkdir ${dir}/du_logs/daily
    mkdir ${dir}/du_logs/weekly
    mkdir ${dir}/du_logs/monthly
fi

# Log disk usage daily
currdate=$(date +"%Y%m%d")
du -sh -c ${dir}/* 2> /dev/null | sort -h -r > ${dir}/du_logs/daily/${currdate}.txt

# Log weekly disk usage every Saturday
if [ $(date +'%u') -eq 6 ]; then
    cp ${dir}/du_logs/daily/${currdate}.txt ${dir}/du_logs/weekly/
fi

# Log disk usage on the first of every month
if [ $(date +'%e') -eq 1 ]; then
    cp ${dir}/du_logs/daily/${currdate}.txt ${dir}/du_logs/monthly/
fi

# Clean log directories.
# Keep daily logs for a week and weekly logs for 90 days
tmpwatch 7d ${dir}/du_logs/daily
tmpwatch 90d ${dir}/du_logs/weekly
