""" A utility to generate make file dependencies for Python files.

This is designed to be run from a makefile. The PYTHONPATH environment
variable must be set for the file being analyzed.

"""
import os
import sys
import importlib.util

USAGE = """
This utility scans a Python source file for dependencies relative to the
current directory and outputs a make compatible dependency which can then
be included in a make file.

Usage: python pdeps.py <python_file>
  python_file = The Python source file to analyze.
"""

if len(sys.argv) < 2:
    print(USAGE)
    exit(1)

python_file = sys.argv[1]

cwd = os.getcwd()
sys.path.append(cwd)

print("# Dependencies for: {}".format(python_file))

# Load the target script.
spec = importlib.util.spec_from_file_location('mod', python_file)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

# Gather the dependencies for modules imported relative to the current
# directory.
deps = []
for k in sys.modules.keys():
    if hasattr(sys.modules[k], '__file__'):
        m = sys.modules[k]
        if m.__file__ is not None and cwd in m.__file__:
            deps += [m.__file__]

# Generate the make compatible dependencies.
# NOTE: This assumes .RECIPEPREFIX in the top make file has been set
# to '>'.
s = '{}:'.format(os.path.realpath(python_file))
for d in deps:
    s += ' \\\n'
    s += '  {}'.format(d)
s += '\n> touch $@'
print(s)
