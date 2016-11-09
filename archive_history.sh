#!/bin/bash
#
# archive_history.sh
# 
# Limit .bash_history to 10k lines and archive overflow.
# 
# Copyright (C) 2016 Matthew Stone <mstone5@mgh.harvard.edu>
# Distributed under terms of the MIT license.

PATH=/bin:/usr/bin
HIST=$HOME/.bash_history

max_lines=10000
linecount=$(wc -l < $HIST)

if [[ $linecount -gt $max_lines ]]; then
  prune=$(($linecount - $max_lines))

  head -n $prune $HIST >> ${HIST}.archive
  sed -e"1,"${prune}"d" $HIST > ${HIST}.tmp
  mv ${HIST}.tmp ${HIST}
fi

