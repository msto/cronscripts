#!/bin/bash
#
# log_jobs.sh
# 
# Log finished LSF jobs.
#
# By default, LSF logs completed jobs for one hour. This script logs all
# finished jobs to a user-specified file.
# 
# Copyright (C) 2015 Matthew Stone <mstone5@mgh.harvard.edu>
# Distributed under terms of the MIT license.

PATH=/bin:/usr/bin

# Cron does not load lsf environment by default. Update dirpaths if needed.
export LSF_SERVERDIR=/hptc_cluster/lsf/8.0/linux2.6-glibc2.3-x86_64/etc
export LSF_LIBDIR=/hptc_cluster/lsf/8.0/linux2.6-glibc2.3-x86_64/lib
export LSF_BINDIR=/hptc_cluster/lsf/8.0/linux2.6-glibc2.3-x86_64/bin
export LSF_INCLUDEDIR=/hptc_cluster/lsf/8.0/include
export LSF_ENVDIR=/hptc_cluster/lsf/conf
PATH=$PATH:$LSF_BINDIR

# log=$HOME/jobs.log
log=$1
bjobs -wd 2> /dev/null \
  | sed '1d' \
  | awk -v OFS="\t" '{print $1, $3, $7, $8" "$9" "$10}' \
  >> $log

sort $log | uniq > ${log}.tmp
mv ${log}.tmp $log
