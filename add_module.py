#!/usr/bin/env python

import sys
import os
from argparse import ArgumentParser, RawTextHelpFormatter
from subprocess import call
from pathlib import Path

editor = os.environ.get('EDITOR', 'vim')

parser = ArgumentParser(
    formatter_class=RawTextHelpFormatter,
    description="""Utility program for adding and modifying modulefiles.

Creates a modulefile at /apps/modulefiles/lab/miket/${module}/${version}.
The modulefile adds /apps/lab/miket/${module}/${version} to $PATH by default.\
""")

parser.add_argument('module', help='Module name')
parser.add_argument('version', help='Module version')
parser.add_argument('-b', '--bin-root', default=False, action='store_true',
                    help='Add ${module}/${version}/bin to $PATH instead.')
parser.add_argument('-f', '--overwrite', default=False, action='store_true',
                    help='Overwrite existing modulefile.')
parser.add_argument('-e', '--edit', default=False, action='store_true',
                    help='Open modulefile in editor. If modulefile does not '
                    'exist,\ndefault template will be written first.')
args = parser.parse_args()

root_dir = Path('/apps/modulefiles/lab/miket')
template = Path('/apps/modulefiles/lab/miket/template')

# Make directory for software if it was not previously installed
module_dir = root_dir / args.module
if not module_dir.is_dir():
    module_dir.mkdir()

# Create modulefile for this version
modulefile = module_dir / args.version
if modulefile.exists():
    if args.edit:
        call([editor, str(modulefile)])
        sys.exit(0)
    if not args.overwrite:
        sys.stderr.write('Modulefile already exists! Use -f to overwrite.\n')
        sys.exit(1)

if args.bin_root:
    path = '${module}_root/bin'.format(module=args.module)
else:
    path = '${module}_root'.format(module=args.module)

template = """#%Module1.0
#
# {module} v{version}
#
proc ModulesHelp {{ }} {{
        global version

        puts stderr "\tThis loads {module}-{version} environment"
}}

module-whatis   "Loads {module}-{version} environment"

set     {module}version    {version}
set     {module}_root      /apps/lab/miket/{module}/{version}
prepend-path    PATH    {path}
""".format(module=args.module, version=args.version, path=path)

with modulefile.open('w') as m:
    m.write(unicode(template))

if args.edit:
    call([editor, str(modulefile)])
