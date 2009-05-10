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
#
# Try the following:
# $ ./write_date.sh now.out
# $ cat now.out
#
# $ ./write_date.sh now.out
# $ cat now.out
#
# $ ./write_date.sh -f now.out
# $ cat now.out

# source shflags
. ../src/shflags

# configure shflags
DEFINE_boolean 'force' false 'force overwriting' 'f'
FLAGS_HELP="USAGE: $0 [flags] filename"


write_date()
{
  date >"$1"
}

die()
{
  [ $# -gt 0 ] && echo "error: $@" >&2
  flags_help
  exit 1
}


# parse the command-line
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# check for filename
[ $# -gt 0 ] || die 'filename missing'
filename=$1

[ -f "${filename}" -a ${FLAGS_force} -eq ${FLAGS_FALSE} ] \
    && die 'filename exists; not overwriting'
write_date "${filename}"
