#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# shFlags unit test for the flag definition methods
#
# Copyright 2008-2017 Kate Ward. All Rights Reserved.
# Released under the Apache 2.0 license.
#
# Author: kate.ward@forestent.com (Kate Ward)
# https://github.com/kward/shflags
#
### ShellCheck (http://www.shellcheck.net/)
# Disable source following.
#   shellcheck disable=SC1090,SC1091

# TODO(kward): assert on FLAGS errors
# TODO(kward): testNonStandardIFS()

# Exit immediately if a pipeline or subshell exits with a non-zero status.
#set -e

# Treat unset variables as an error.
set -u

# These variables will be overridden by the test helpers.
returnF="${TMPDIR:-/tmp}/return"
stdoutF="${TMPDIR:-/tmp}/STDOUT"
stderrF="${TMPDIR:-/tmp}/STDERR"

# Load test helpers.
. ./shflags_test_helpers


testStringsWithQuotes() {
    _testValidStrings -s "Single Quote Flag's Test"
    _testValidStrings -s "Double Quote \"Flag\" Test"
    _testValidStrings -s "Mixed Quote's \"Flag\" Test"
    _testValidStrings -s 'Mixed Quote'\''s "Flag" Test'
}

_testValidStrings()
{
  flag=$1
  value=$2

  FLAGS "${flag}" "${value}" >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue "'FLAGS ${flag} ${value}' returned a non-zero result (${r3turn})" \
      ${r3turn}
  # shellcheck disable=SC2154
  assertEquals "string (${value}) test failed." "${value}" "${FLAGS_str}"
  if [ ${r3turn} -eq "${FLAGS_TRUE}" ]; then
    assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  else
    # Validate that an error is thrown for unsupported getopt uses.
    assertFatalMsg '.* spaces in options'
  fi
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"
}


oneTimeSetUp() {
  th_oneTimeSetUp

  if flags_getoptIsStd; then
    th_warn 'Standard version of getopt found. Enhanced tests will be skipped.'
  else
    th_warn 'Enhanced version of getopt found. Standard tests will be skipped.'
  fi
}

setUp() {
  DEFINE_boolean bool false 'boolean test' 'b'
  DEFINE_float float 0.0 'float test' 'f'
  DEFINE_integer int 0 'integer test' 'i'
  DEFINE_string str '' 'string test' 's'
}

tearDown() {
  flags_reset
}

# Load and run shUnit2.
# shellcheck disable=SC2034
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. "${TH_SHUNIT}"
