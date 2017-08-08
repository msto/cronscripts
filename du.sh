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
mkdir -p ${dir}/du_logs
mkdir -p ${dir}/du_logs/daily
mkdir -p ${dir}/du_logs/weekly
mkdir -p ${dir}/du_logs/monthly

# Log disk usage daily
currdate=$(date +"%Y%m%d")
du -s -c ${dir}/* 2> /dev/null | sort -h -r > ${dir}/du_logs/daily/${currdate}.txt

# Log weekly disk usage every Saturday
if [ $(date +'%u') -eq 6 ]; then
    cp ${dir}/du_logs/daily/${currdate}.txt ${dir}/du_logs/weekly/
    cp ${dir}/du_logs/daily/${currdate}_raw.txt ${dir}/du_logs/weekly/
fi

# Log disk usage on the first of every month
if [ $(date +'%e') -eq 1 ]; then
    cp ${dir}/du_logs/daily/${currdate}.txt ${dir}/du_logs/monthly/
    cp ${dir}/du_logs/daily/${currdate}_raw.txt ${dir}/du_logs/monthly/
fi

# Clean log directories.
# Keep daily logs for a week and weekly logs for 90 days
# Keep daily logs for 30 days and weekly logs for a year
tmpwatch 30d ${dir}/du_logs/daily
tmpwatch 365d ${dir}/du_logs/weekly
