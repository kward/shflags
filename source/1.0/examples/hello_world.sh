#!/bin/sh

# source shflags
. ../src/shflags

# define a 'name' command-line string flag
DEFINE_string 'name' 'world' 'name to say hello to' 'n'

# parse the command-line
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

echo "Hello, ${FLAGS_name}!"
