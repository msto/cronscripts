#!/bin/bash
#
# du.sh
# Copyright (C) 2015 Matthew Stone <mstone5@mgh.harvard.edu>
#
# Distributed under terms of the MIT license.
#
PATH=/bin:/usr/bin

# Add python, ncdu, and parsing util
python=/apps/lab/miket/anaconda/4.0.5/envs/py35/bin/python
ncdu=/apps/lab/miket/ncdu/1.12/bin/ncdu
ncdu_parser=/PHShome/my520/code/cronscripts/parse_ncdu.py

dir=$1

# Initialize logging if necessary
mkdir -p ${dir}/du_logs
mkdir -p ${dir}/du_logs/daily
mkdir -p ${dir}/du_logs/weekly
mkdir -p ${dir}/du_logs/monthly

# Log disk usage weekly
currdate=$(date +"%Y%m%d")
NCDU_LOG=${dir}/du_logs/weekly/${currdate}.ncdu.json.gz
NCDU_CONVERT=${dir}/du_logs/weekly/${currdate}.dirstats.csv.gz

$ncdu -x -r -0 --si -o - $dir | gzip -c > $NCDU_LOG
$python $ncdu_parser -z ${NCDU_LOG} ${NCDU_CONVERT}

# Log weekly disk usage every Saturday
# if [ $(date +'%u') -eq 6 ]; then
    # cp ${NCDU_LOG} ${dir}/du_logs/weekly/
    # cp ${NCDU_CONVERT} ${dir}/du_logs/weekly/
# fi

# Log disk usage on the first of every month
# if [ $(date +'%e') -eq 1 ]; then
    # cp ${NCDU_LOG} ${dir}/du_logs/monthly/
    # cp ${NCDU_CONVERT} ${dir}/du_logs/monthly/
# fi

# Clean log directories.
# Keep daily logs for a week and weekly logs for 90 days
# Keep daily logs for 30 days and weekly logs for a year
# tmpwatch 30d ${dir}/du_logs/daily
# tmpwatch 365d ${dir}/du_logs/weekly
