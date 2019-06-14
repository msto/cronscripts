#!/bin/bash
#
# ncdu.sh
# Copyright (C) 2019 Matthew Stone
#
# Distributed under terms of the MIT license.
#
PATH=/bin:/usr/bin

# Add python, ncdu, and parsing util
python=/mnt/home/mstone/local/miniconda3/envs/py36/bin/python3.6
ncdu=/mnt/dv/wid/projects2/Roy-common/programs/thirdparty/ncdu/1.14/bin/ncdu
ncdu_parser=/mnt/home/mstone/code/cronscripts/parse_ncdu.py

dir=$1

# Establish daily/weekly/monthly directories
DAILY_DIR=${dir}/du_logs/daily
WEEKLY_DIR=${dir}/du_logs/weekly
MONTHLY_DIR=${dir}/du_logs/monthly

# Initialize logging if necessary
mkdir -p ${DAILY_DIR}
mkdir -p ${WEEKLY_DIR}
mkdir -p ${MONTHLY_DIR}

# Log disk usage daily
currdate=$(date +"%Y%m%d")
NCDU_LOG=${DAILY_DIR}/${currdate}.ncdu.json.gz
# NCDU_CONVERT=${DAILY_DIR}/${currdate}.dirstats.csv.gz

$ncdu -x -r -0 --si -o - $dir | gzip -c > $NCDU_LOG
# $python $ncdu_parser -z ${NCDU_LOG} ${NCDU_CONVERT}

# Log weekly disk usage every Saturday
if [ $(date +'%u') -eq 6 ]; then
    cp ${NCDU_LOG} ${WEEKLY_DIR}/
    # cp ${NCDU_CONVERT} ${WEEKLY_DIR}/
fi

# Log disk usage on the first of every month
if [ $(date +'%e') -eq 1 ]; then
    cp ${NCDU_LOG} ${MONTHLY_DIR}/
    # cp ${NCDU_CONVERT} ${MONTHLY_DIR}/
fi

# Clean log directories.
# Keep daily logs for 30 days and weekly logs for a year
# tmpwatch 30d ${DAILY_DIR}
# tmpwatch 365d ${WEEKLY_DIR}

# tmpwatch not installed on WID machines, so use ls
if [[ $(ls ${DAILY_DIR} | wc -l) -gt 7 ]]; then
  ls -t ${DAILY_DIR} | cat | sed '7d' | xargs rm
fi

if [[ $(ls ${WEEKLY_DIR} | wc -l) -gt 30 ]]; then
  ls -t ${WEEKLY_DIR} | cat | sed '30d' | xargs rm
fi
