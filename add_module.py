#!/usr/bin/env python
"""
Utility program for adding and modifying modulefiles.

Creates a modulefile at /apps/modulefiles/lab/miket/${module}/${version}.
The modulefile adds /apps/lab/miket/${module}/${version} to $PATH by default.
"""

import sys
#print(sys.version_info)
import os
from argparse import ArgumentParser, RawDescriptionHelpFormatter
from subprocess import call
from pathlib import Path

editor = os.environ.get('EDITOR', 'vim')

parser = ArgumentParser(
    formatter_class=RawDescriptionHelpFormatter,
    description=__doc__)
parser.add_argument('module', help='Module name')
parser.add_argument('version', help='Module version')
parser.add_argument('-b', '--bin-root', default=False, action='store_true',
                    help='Add ${module}/${version}/bin to $PATH instead.')
parser.add_argument('-f', '--overwrite', default=False, action='store_true',
                    help='Overwrite existing modulefile.')
parser.add_argument('-e', '--edit', default=False, action='store_true',
                    help='Open modulefile in editor. If modulefile does not '
                    'exist, default template will be written first.')
args = parser.parse_args()

MODULEFILES = os.environ.get('MODULEFILES', '/modulefiles')
MODULES = os.environ.get('MODULES', '/modules')
root_dir = Path(MODULEFILES)
template = Path('~/local/cronscripts/modulefile.template')

# Make directory for software if it was not previously installed
modulefile_dir = root_dir / args.module
if not modulefile_dir.is_dir():
    modulefile_dir.mkdir()

# Create modulefile for this version
modulefile = modulefile_dir / args.version
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
set     {module}_root      {MODULES}/{module}/{version}
prepend-path    PATH    {path}
""".format(module=args.module, version=args.version, path=path, MODULES=MODULES)

with modulefile.open('w') as m:
    if sys.version_info.major >= 3:
        m.write(template)
    else:
        m.write(unicode(template))

if args.edit:
    call([editor, str(modulefile)])
