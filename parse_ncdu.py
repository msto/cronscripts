#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright © 2017 Matthew Stone <mstone5@mgh.harvard.edu>
# Distributed under terms of the MIT license.

"""

"""

import argparse
import os
import csv
import gzip
import datetime
import contextlib
import json
import humanfriendly


class NcduParser:
    def __init__(self, ncdu_data, logfile):
        self.ncdu_data = ncdu_data
        self.dirstats = {}
        self.depths = {}
        self.logfile = csv.writer(logfile, delimiter=',',
                                  quoting=csv.QUOTE_MINIMAL)

    def parse_ncdu(self):
        # First three entries of ncdu log are metadata,
        # filesize data is contained in list at 4th entry
        topdir = self.ncdu_data[3]
        self.depths[""] = 0
        self.parse_ncdu_subdir(topdir, "")

    def parse_ncdu_subdir(self, ncdu_entry, parent_dir):
        """
        Recursively compute directory usage

        Parameters
        ----------
        ncdu_entry : list or dict
        parent_dir : str

        Returns
        -------
        dirname : str
        usage : int
        """

        # Directories are represented as lists
        if isinstance(ncdu_entry, list):
            # First instance in list is metadata of directory
            dirname = os.path.join(parent_dir, ncdu_entry[0]['name'])
            total_usage = ncdu_entry[0]['dsize']
            self.depths[dirname] = self.depths[parent_dir] + 1

            for entry in ncdu_entry[1:]:
                name, usage = self.parse_ncdu_subdir(entry, dirname)
                total_usage += usage

            # Would be better to store all intermediate resuts in dict,
            # but I don't want to worry about filtering non-directories
            self.dirstats[dirname] = total_usage

            return dirname, total_usage

        elif isinstance(ncdu_entry, dict):
            fname = os.path.join(parent_dir, ncdu_entry['name'])
            return fname, ncdu_entry['dsize']

        else:
            dtype = type(ncdu_entry)
            raise Exception('Invalid entry type: {0}'.format(dtype))

    def write_dirstats(self):
        header = 'directory size_human size_bytes date depth'.split()
        self.logfile.writerow(header)

        date = datetime.date.today()

        for dirname in sorted(self.dirstats.keys()):
            dsize = self.dirstats[dirname]
            hum_dsize = humanfriendly.format_size(dsize, binary=True)

            row = [dirname, hum_dsize, dsize, date, self.depths[dirname]]
            self.logfile.writerow(row)


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('ncdu_log')
    parser.add_argument('fout')
    parser.add_argument('-z', '--gzip', action='store_true', default=False,
                        help='Gzip output table')
    args = parser.parse_args()

    with contextlib.ExitStack() as cm:
        if args.ncdu_log.endswith('gz'):
            ncdu_logfile = cm.enter_context(gzip.open(args.ncdu_log, 'rt'))
        else:
            ncdu_logfile = cm.enter_context(open(args.ncdu_log))

        if args.gzip:
            fout = cm.enter_context(gzip.open(args.fout, 'wt'))
        else:
            fout = cm.enter_context(open(args.fout), 'w')

        ncdu_data = json.load(ncdu_logfile)
        ncdu_parser = NcduParser(ncdu_data, fout)
        ncdu_parser.parse_ncdu()
        ncdu_parser.write_dirstats()


if __name__ == '__main__':
    main()
