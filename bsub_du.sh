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

dir=$1

mkdir -p ${dir}/du_logs/lsf_logs

currdate=$(date +"%Y%m%d")

bsub -J "du_${currdate}_${dir}" -sla miket_sc -q normal -o ${dir}/du_logs/lsf_logs/${currdate}_du.out "/bin/bash /PHShome/my520/code/cronscripts/du.sh ${dir}" > /dev/null
