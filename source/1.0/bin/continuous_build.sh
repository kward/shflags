# /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2010 Kate Ward. All Rights Reserved.
# Author: kate.ward@forestent.com (Kate Ward)
#
# Continuous build script for shell library testing.
#
# Sample usages:
# $ blah

# treat unset variables as an error
set -u

# global constants
ARGV0=`basename "$0"`
ARGV0_DIR=`dirname "$0"`
SHLIB_DIR="${ARGV0_DIR}/../lib"

# load libraries
. ${SHFLAGS_LIB:-${SHLIB_DIR}/shflags} \
    || (echo 'unable to load shflags library' >&2; exit 1)
. ${VERSIONS_LIB:-${SHLIB_DIR}/versions} \
    || (echo 'unable to load versions library' >&2; exit 1)

OUTPUT_FILE="${VERSIONS_OS_NAME}_${VERSIONS_OS_RELEASE}"

# define flags
DEFINE_string 'command' '' 'the command to start a build' 'c'
DEFINE_string 'watch' '' 'file to watch for changes' 'w'
DEFINE_string 'watch_from' '' 'file containing filenames to watch' 'W'
DEFINE_string 'output' "${OUTPUT_FILE}" 'output file to write to' 'o'
DEFINE_string 'output_dir' '.' 'directory to write output file' 'O'
DEFINE_integer 'pause' 60 'pause between successive runs (sec)' 'p'

FLAGS_HELP="USAGE: ${ARGV0} [flags]"

#------------------------------------------------------------------------------
# functions
#

# This function exits the script, optionally printing a message
#
# Args:
#   message: string: an error message to be output (optional)
# Output:
#   string: usable flags
die() {
  [ $# -ne 0 ] && echo "$@" >&2
  flags_help
  exit 1
}

# Function to give the current date in ISO format
#
# Args:
#   none
# Output:
#   string: isodate
isodate() {
  date -u '+%Y%m%dT%H%M%SZ'
}

age() {
  awkScript=''
  case ${VERSIONS_OS_NAME} in
    FreeBSD|Solaris) awkScript='{print $6,$7,$8}' ;;
    Linux) awkScript='{print $6,$7}' ;;
    *) echo "unrecognized OS name (${VERSIONS_OS_NAME})" >&2 ;;
  esac
  ls -l "$1" |awk "${awkScript}"
}

#------------------------------------------------------------------------------
# main
#

main()
{
  # checks
  [ -n "${FLAGS_command}" ] || die 'command required'
  [ -z "${FLAGS_watch}" -a -z "${FLAGS_watch_from}" ] \
    && die 'one of watch or watch_from required'
  [ -n "${FLAGS_watch}" -a -n "${FLAGS_watch_from}" ] \
    && die 'only one of watch or watch_from can be specified'
  [ -r "${FLAGS_watch}" ] || die 'unable to read watch file'
  [ -w "${FLAGS_output_dir}" ] || die 'unable to write to output directory'

  watchAge=`age "${FLAGS_watch}"`
  watchAgePrev=${watchAge}

  # build
  while true; do
    if [ ! "${watchAge}" == "${watchAgePrev}" ]; then
      date=`isodate`
      echo "building ${VERSIONS_OS_NAME}-${VERSIONS_OS_RELEASE} @ ${date}"
      outputFileDated="${FLAGS_output}-${date}"
      ${FLAGS_command} >"${FLAGS_output_dir}/${outputFileDated}" 2>&1

      ( cd "${FLAGS_output_dir}";
        rm -f "${FLAGS_output}";
        ln -s "${outputFileDated}" "${FLAGS_output}";
        grep FAIL "${FLAGS_output}"; )

      watchAgePrev=${watchAge}
    fi

    watchAge=`age "${FLAGS_watch}"`
    if [ "${watchAge}" == "${watchAgePrev}" ]; then
      echo 'sleeping...'
      while [ "${watchAge}" == "${watchAgePrev}" ]; do
        sleep ${FLAGS_pause}
        watchAge=`age "${FLAGS_watch}"`
      done
    fi
  done
}

# execute main() if this is run in standalone mode (i.e. not in a unit test)
argv0=`echo "${ARGV0}" |sed 's/_test$//;s/_test\.sh$//'`
if [ "${ARGV0}" = "${argv0}" ]; then
  FLAGS "$@" || exit $?
  eval set -- "${FLAGS_ARGV}"
  if [ $# -gt 0 ]; then main "$@"; else main; fi
fi
