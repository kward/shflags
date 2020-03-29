#!/bin/sh
#
# This is the proverbial 'Hello, world!' script to demonstrate the most basic
# functionality of shFlags.
#
# This script demonstrates accepts a single command-line flag of '-n' (or
# '--name'). If a name is given, it is output, otherwise the default of 'world'
# is output.

# Source shflags.
. ../shflags

# Define a 'name' command-line string flag.
DEFINE_string 'name' 'world' 'name to say hello to' 'n'

# Parse the command-line.
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

echo "Hello, ${FLAGS_name}!"
