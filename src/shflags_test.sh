#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# shFlags unit test suite runner.
#
# This script runs all the unit tests that can be found, and generates a nice
# report of the tests.

MY_NAME=`basename $0`
MY_PATH=`dirname $0`

PREFIX='shflags_test_'
SHELLS='/bin/sh /bin/bash /bin/dash /bin/ksh /bin/pdksh /bin/zsh'
TESTS=''
for test in ${PREFIX}[a-z]*.sh; do
  TESTS="${TESTS} ${test}"
done

# Load libraries.
. ../lib/versions
. ./shflags_test_helpers

usage() {
  echo "usage: ${MY_NAME} [-e key=val ...] [-s shell(s)] [-t test(s)]"
}

env=''

# Process command line flags.
while getopts 'e:hs:t:' opt; do
  case ${opt} in
    e)  # set an environment variable
      key=`expr "${OPTARG}" : '\([^=]*\)='`
      val=`expr "${OPTARG}" : '[^=]*=\(.*\)'`
      if [ -z "${key}" -o -z "${val}" ]; then
        usage
        exit 1
      fi
      eval "${key}='${val}'"
      export ${key}
      env="${env:+${env} }${key}"
      ;;
    h) usage; exit 0 ;;  # help output
    s) shells=${OPTARG} ;;  # list of shells to run
    t) tests=${OPTARG} ;;  # list of tests to run
    *) usage; exit 1 ;;
  esac
done
shift `expr ${OPTIND} - 1`

# Fill shells and/or tests.
shells=${shells:-${SHELLS}}
tests=${tests:-${TESTS}}

# Error checking.
if [ -z "${tests}" ]; then
  th_error 'no tests found to run; exiting'
  exit 1
fi

cat <<EOF
#------------------------------------------------------------------------------
# System data.
#

$ uname -mprsv
`uname -mprsv`

OS Name: `versions_osName`
OS Version: `versions_osVersion`

### Test run info.
shells: ${shells}
tests: ${tests}
EOF
for key in ${env}; do
  eval "echo \"${key}=\$${key}\""
done

# Run tests.
for shell in ${shells}; do
  echo

  cat <<EOF

#------------------------------------------------------------------------------
# Running the test suite with ${shell}.
#
EOF
  # Check for existence of shell.
  if [ ! -x ${shell} ]; then
    th_warn "unable to run tests with the ${shell} shell"
    continue
  fi

  shell_name=`basename ${shell}`
  shell_version=`versions_shellVersion "${shell}"`

  echo "shell name: ${shell_name}"
  echo "shell version: ${shell_version}"

  # Execute the tests.
  for suite in ${tests}; do
    suiteName=`expr "${suite}" : "${PREFIX}\(.*\).sh"`
    echo
    echo "--- Executing the '${suiteName}' test suite. ---"
    ( exec ${shell} ./${suite} 2>&1; )
  done
done
