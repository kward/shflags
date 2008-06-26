#!/bin/sh

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
