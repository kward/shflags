#!/bin/sh
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# This script does the very simple job of echoing some text. If a '-d' (or
# '--debug') flag is given, additinal "debug" output is enabled.
#
# This script demonstrates the use of a boolean flag to enable custom
# functionality in a script.

# source shflags
. ../src/shflags

debug() { [ ${FLAGS_debug} -eq ${FLAGS_TRUE} ] && echo "DEBUG: $@" >&2; }

# define flags
DEFINE_boolean 'debug' false 'enable debug mode' 'd'

# parse the command-line
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

debug 'debug mode enabled'
echo 'something interesting'
