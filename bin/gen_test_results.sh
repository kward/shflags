#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# This script runs the provided unit tests and sends the output to the
# appropriate file.

# Treat unset variables as an error.
set -u

die() {
  [ $# -gt 0 ] && echo "error: $@" >&2
  exit 1
}

BASE_DIR="`dirname $0`/.."
LIB_DIR="${BASE_DIR}/lib"

# Load libraries.
. ${LIB_DIR}/shflags || die 'unable to load shflags library'
. ${LIB_DIR}/shlib || die 'unable to load shlib library'
. ${LIB_DIR}/versions || die 'unable to load versions library'

# Redefining BASE_DIR now that we have the shlib functions.
BASE_DIR=`shlib_relToAbsPath "${BASE_DIR}"`
BIN_DIR="${BASE_DIR}/bin"
SRC_DIR="${BASE_DIR}/src"

os_name=`versions_osName |sed 's/ /_/g'`
os_version=`versions_osVersion`

# Load external flags.
. ${BIN_DIR}/gen_test_results.flags

# Define flags.
DEFINE_boolean force false 'force overwrite' f
DEFINE_string output_dir "`pwd`" 'output dir' d
DEFINE_string output_file "${os_name}-${os_version}.txt" 'output file' o
DEFINE_boolean dry_run false "supress logging to a file" n

main() {
  # Determine output filename.
  output="${FLAGS_output_dir:+${FLAGS_output_dir}/}${FLAGS_output_file}"
  output=`shlib_relToAbsPath "${output}"`

  # Checks.
  [ -n "${FLAGS_suite:-}" ] || die 'suite flag missing'

  if [ ${FLAGS_dry_run} -eq ${FLAGS_FALSE} -a -f "${output}" ]; then
    if [ ${FLAGS_force} -eq ${FLAGS_TRUE} ]; then
      rm -f "${output}"
    else
      echo "not overwriting '${output}'" >&2
      exit ${FLAGS_ERROR}
    fi
  fi
  if [ ${FLAGS_dry_run} -eq ${FLAGS_FALSE} ]; then
    touch "${output}" 2>/dev/null || die "unable to write to '${output}'"
  fi

  # Run tests.
  (
    cd "${SRC_DIR}";
    if [ ${FLAGS_dry_run} -eq ${FLAGS_FALSE} ]; then
      ./${FLAGS_suite} |tee "${output}"
    else
      ./${FLAGS_suite}
    fi
  )

  if [ ! ${FLAGS_dry_run} ]; then
    echo >&2
    echo "output written to '${output}'" >&2
  fi
}

FLAGS "$@" || exit $?
[ ${FLAGS_help} -eq ${FALSE} ] || exit
eval set -- "${FLAGS_ARGV}"
main "$@"
