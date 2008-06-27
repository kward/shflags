#!/bin/sh
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# This script takes a filename as input and writes the current date to the
# file. If the file already exists, it will not be overwritten unless the '-f'
# (or '--force') flag is given.
#
# This script demonstrates several types of shFlags functionality.
# - declaration of the FLAGS_HELP variable to customize the help output
# - direct calling of the flags_help() function for script controlled usage
#   output
# - handling of non-flag type command-line arguments that follow the flags

# source shflags
. ../src/shflags

write_date() { date >"$1"; }

# configure shflags
DEFINE_boolean 'force' false 'force overwriting' 'f'
FLAGS_HELP="USAGE: $0 [flags] filename"

# parse the command-line
FLAGS "$@" || exit 1; shift ${FLAGS_ARGC}

# check for filename
if [ $# -eq 0 ]; then
  echo 'error: filename missing' >&2
  flags_help
  exit 1
fi
filename=$1

if [ ! -f "${filename}" ]; then
  write_date "${filename}"
else
  if [ ${FLAGS_force} -eq ${FLAGS_TRUE} ]; then
    write_date "${filename}"
  else
    echo 'warning: filename exists; not overwriting' >&2
    exit 2
  fi
fi
