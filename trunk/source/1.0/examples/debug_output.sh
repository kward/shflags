#!/bin/sh

# source shflags
. ../src/shflags

debug() { [ ${FLAGS_debug} -eq ${FLAGS_TRUE} ] && echo "DEBUG: $@" >&2; }

# define flags
DEFINE_boolean 'debug' false 'enable debug mode' 'd'

# parse the command-line
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

debug 'debug mode enabled'
echo 'something interesting'
