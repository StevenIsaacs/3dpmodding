""" A helper utility to create a make file segment containing variables
describing the partitions in an OS image file. This is designed to parse
a JSON file produced by the command:
  sfdisk -l -json <image_file>
"""

import os
import sys
import json

USAGE = """
This utility parses a JSON file containing partition information for an OS
image file and generates a corresponding makefile segment which is output
to the console which can then be redirected to a file.

Usage python3 os-image-partitions.py <json_file>
"""

if len(sys.argv) < 2:
    print(USAGE)
    exit(1)

json_file = sys.argv[1]

print(json_file)
f = open(json_file)
j = json.load(f)

h = """
ifeq (${MAKECMDGOALS},help-partitions)
define HelpPartitionsMsg
This make segment describes the partitions in a Linux OS image file.

Defines:
"""
s = '# Partitions from: {}\n'.format(os.path.realpath(json_file))
c = 0
for p in j['partitiontable']['partitions']:
    c += 1
    s += 'OS_IMAGE_P{}_OFFSET = {}\n'.format(c, p['start'] * 512)
    s += 'OS_IMAGE_P{}_SIZE = {}\n'.format(c, p['size'] * 512)
    h += 'OS_IMAGE_P{}_OFFSET = ${{OS_IMAGE_P{}_OFFSET}}\n'.format(c, c)
    h += 'OS_IMAGE_P{}_SIZE = ${{OS_IMAGE_P{}_SIZE}}\n'.format(c, c)

s += h
# The following causes Python linters to complain about using a tab for
# indentation. The tab is necessary because of make.
s += """
endef

export HelpPartitionsMsg
help-partitions:
	@echo \"$$HelpPartitionsMsg\" | less
endif
"""

print(s)
