#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# This script runs the provided unit tests and sends the output to the
# appropriate file.
#

# treat unset variables as an error
set -u

die()
{
  [ $# -gt 0 ] && echo "error: $@" >&2
  exit 1
}

relToAbsPath()
{
  path_=$1

  # prepend current directory to relative paths
  echo "${path_}" |grep '^/' >/dev/null || path_="`pwd`/${path_}"

  # clean up the path
  old_=${path_}
  while true; do
    new_=`echo "${old_}" |sed 's/[^/]*\/\.\.\/*//g;s/\/\.\//\//'`
    [ "${old_}" = "${new_}" ] && break
    old_=${new_}
  done

  echo "${new_}"
  unset path_ old_ new_
}

BASE_DIR="`dirname $0`/.."
BASE_DIR=`relToAbsPath "${BASE_DIR}"`

LIB_DIR="${BASE_DIR}/lib"
SRC_DIR="${BASE_DIR}/src"

# load libraries
. ${SRC_DIR}/shflags || die 'unable to load shflags library'
. ${LIB_DIR}/versions || die 'unable to load versions library'

os_name=`versions_osName |tr ' ' '_'`
os_release=`versions_osRelease |tr ' ' '_'`

DEFINE_boolean force false 'force overwrite' f
DEFINE_string output_dir "`pwd`" 'output dir' d
DEFINE_string output_file "${os_name}-${os_release}.txt" 'output file' o
FLAGS "${@:-}" || exit $?
eval set -- "${FLAGS_ARGV}"

# determine output filename
output="${FLAGS_output_dir:+${FLAGS_output_dir}/}${FLAGS_output_file}"
output=`relToAbsPath "${output}"`

# checks
if [ -f "${output}" ]; then
  if [ ${FLAGS_force} -eq ${FLAGS_TRUE} ]; then
    rm -f "${output}"
  else
    echo "not overwriting '${output}'" >&2
    exit ${FLAGS_ERROR}
  fi
fi
touch "${output}" 2>/dev/null || die "unable to write to '${output}'"

# run tests
( cd "${SRC_DIR}"; ./shflags_test.sh |tee "${output}" )

echo >&2
echo "output written to '${output}'" >&2
