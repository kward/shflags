#!/bin/sh
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

# Source shFlags.
. ../shflags

# Configure shFlags.
DEFINE_boolean 'force' false 'force overwriting' 'f'
FLAGS_HELP="USAGE: $0 [flags] filename"

die() {
  [ $# -gt 0 ] && echo "error: $@"
  flags_help
  exit 1
}

# Parse the command-line.
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

# Check for filename on command-line.
[ $# -gt 0 ] || die 'filename missing.'
filename=$1

# Redirect STDOUT to the file ($1). This seemingly complicated method using exec
# is used so that a potential race condition between checking for the presence
# of the file and writing to the file is mitigated.
if [ ${FLAGS_force} -eq ${FLAGS_FALSE} ] ; then
  [ ! -f "${filename}" ] || die "file \"${filename}\" already exists."
  # Set noclobber, redirect STDOUT to the file, first saving STDOUT to fd 4.
  set -C
  exec 4>&1 >"${filename}"  # This fails if the file exists.
else
  # Forcefully overwrite (clobber) the file.
  exec 4>&1 >|"${filename}"
fi

# What time is it?
date

# Restore STDOUT from file descriptor 4, and close fd 4.
exec 1>&4 4>&-

echo "The current date was written to \"${filename}\"."
