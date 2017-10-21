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

testGetoptStandard() {
  _flags_getoptStandard '-b' >"${stdoutF}" 2>"${stderrF}"
  rslt=$?
  assertTrue "didn't parse valid flag 'b'" ${rslt}
  th_showOutput ${rslt} "${stdoutF}" "${stderrF}"

  _flags_getoptStandard '-x' >"${stdoutF}" 2>"${stderrF}"
  assertFalse "parsed invalid flag 'x'" $?
}

testGetoptEnhanced() {
  flags_getoptIsEnh || return

  _flags_getoptEnhanced '-b' >"${stdoutF}" 2>"${stderrF}"
  assertTrue "didn't parse valid flag 'b'" $?
  _flags_getoptEnhanced '--bool' >"${stdoutF}" 2>"${stderrF}"
  assertTrue "didn't parse valid flag 'bool'" $?

  _flags_getoptEnhanced '-x' >"${stdoutF}" 2>"${stderrF}"
  assertFalse "parsed invalid flag 'x'" $?
  _flags_getoptEnhanced '--xyz' >"${stdoutF}" 2>"${stderrF}"
  assertFalse "parsed invalid flag 'xyz'" $?
}

testValidBoolsShort()
{
  FLAGS -b >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue "-b) FLAGS returned a non-zero result (${r3turn})" ${r3turn}
  value=${FLAGS_bool:-}
  assertTrue "-b) boolean was not true (${value})." "${value}"
  assertFalse '-b) expected no output to STDERR' "[ -s '${stderrF}' ]"
  test ${r3turn} -eq "${FLAGS_TRUE}" -a ! -s "${stderrF}"
  th_showOutput $? "${stdoutF}" "${stderrF}"

  DEFINE_boolean bool2 true '2nd boolean' B
  FLAGS >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue "-B) FLAGS returned a non-zero result (${r3turn})" ${r3turn}
  value=${FLAGS_bool2:-}
  assertTrue "-B) boolean was not true (${value})" "${value}"
  assertFalse '-B) expected no output to STDERR' "[ -s '${stderrF}' ]"
  test ${r3turn} -eq "${FLAGS_TRUE}" -a ! -s "${stderrF}"
  th_showOutput $? "${stdoutF}" "${stderrF}"

  FLAGS -B >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue "-B) FLAGS returned a non-zero result (${r3turn})" ${r3turn}
  value=${FLAGS_bool2:-}
  assertFalse "-B) boolean was not false (${value})" "${value}"
  assertFalse '-B) expected no output to STDERR' "[ -s '${stderrF}' ]"
  test ${r3turn} -eq "${FLAGS_TRUE}" -a ! -s "${stderrF}"
  th_showOutput $? "${stdoutF}" "${stderrF}"
}

# TODO(kate): separate into multiple functions to reflect correct usage
testValidBoolsLong() {
  flags_getoptIsEnh || return

  # Note: the default value of bool is 'false'.

  # Leave flag false.
  FLAGS --nobool >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue "FLAGS returned a non-zero result (${r3turn})" ${r3turn}
  assertFalse '--noXX flag resulted in true value.' "${FLAGS_bool:-}"
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"

  # Flip flag true.
  FLAGS --bool >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue "FLAGS returned a non-zero result (${r3turn})" ${r3turn}
  assertTrue '--XX flag resulted in false value.' "${FLAGS_bool:-}"
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"

  # Flip flag back false.
  FLAGS --nobool >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue "FLAGS returned a non-zero result (${r3turn})" ${r3turn}
  assertFalse '--noXX flag resulted in true value.' "${FLAGS_bool:-}"
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"
}

testValidFloats() {
  _testValidFloats '-f'
  flags_getoptIsEnh || return
  _testValidFloats '--float'
}

_testValidFloats() {
  flag=$1
  for value in ${TH_FLOAT_VALID}; do
    FLAGS "${flag}" "${value}" >"${stdoutF}" 2>"${stderrF}"
    r3turn=$?
    assertTrue "FLAGS ${flag} ${value} returned non-zero result (${r3turn})" \
        ${r3turn}
    # shellcheck disable=SC2154
    assertEquals "float (${flag} ${value}) test failed." "${value}" "${FLAGS_float}"
    assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
    th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"
  done
}

testInvalidFloats()
{
  _testInvalidFloats '-f'
  flags_getoptIsEnh || return
  _testInvalidFloats '--float'
}

_testInvalidFloats()
{
  flag=$1
  for value in ${TH_FLOAT_INVALID}; do
    th_clearReturn
    (
      FLAGS "${flag}" "${value}" >"${stdoutF}" 2>"${stderrF}"
      echo $? >"${returnF}"
    )
    assertFalse "FLAGS (${value}) returned a zero result" "$(th_queryReturn)"
    assertFalse 'expected no output to STDOUT' "[ -s '${stdoutF}' ]"
    assertTrue 'expected output to STDERR' "[ -s '${stderrF}' ]"
  done
}

testValidIntegers() {
  _testValidIntegers '-i'
  flags_getoptIsEnh || return
  _testValidIntegers '--int'
}

_testValidIntegers() {
  flag=$1
  for value in ${TH_INT_VALID}; do
    FLAGS "${flag}" "${value}" >"${stdoutF}" 2>"${stderrF}"
    r3turn=$?
    assertTrue "FLAGS (${value}) returned a non-zero result (${r3turn})" ${r3turn}
    # shellcheck disable=SC2154
    assertEquals "integer (${value}) test failed." "${value}" "${FLAGS_int}"
    assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
    th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"
  done
}

testInvalidIntegers() {
  _testInvalidIntegers '-i'
  flags_getoptIsEnh || return
  _testInvalidIntegers '--int'
}

_testInvalidIntegers() {
  flag=$1
  for value in ${TH_INT_INVALID}; do
    th_clearReturn
    (
      FLAGS "${flag}" "${value}" >"${stdoutF}" 2>"${stderrF}"
      echo $? >"${returnF}"
    )
    assertFalse "invalid integer (${value}) test returned success." "$(th_queryReturn)"
    assertFalse 'expected no output to STDOUT' "[ -s '${stdoutF}' ]"
    assertTrue 'expected output to STDERR' "[ -s '${stderrF}' ]"
  done
}

testValidStrings() {
  _testValidStrings -s single_word
  if flags_getoptIsEnh; then
    _testValidStrings --str single_word
    _testValidStrings --str 'string with spaces'
  fi
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

testMultipleFlags() {
  _testMultipleFlags '-b' '-i' '-f' '-s'
  flags_getoptIsEnh || return
  _testMultipleFlags '--bool' '--int' '--float' '--str'
}

_testMultipleFlags() {
  boolFlag=$1
  intFlag=$2
  floatFlag=$3
  strFlag=$4

  FLAGS \
      "${boolFlag}" \
      "${intFlag}" 567 \
      "${floatFlag}" 123.45678 \
      "${strFlag}" 'some_string' \
      >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue "use of multiple flags returned a non-zero result" ${r3turn}
  assertTrue 'boolean test failed.' "${FLAGS_bool}"
  assertNotSame 'float test failed.' 0 "${FLAGS_float}"
  assertNotSame 'integer test failed.' 0 "${FLAGS_int}"
  assertNotSame 'string test failed.' '' "${FLAGS_str}"
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"
}

_testNonFlagArgs() {
  argc=$1
  shift

  FLAGS "$@" >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue 'parse returned non-zero value.' ${r3turn}
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"

  eval set -- "${FLAGS_ARGV}"
  assertEquals 'wrong count of argv arguments returned.' "${argc}" $#
  assertEquals 'wrong count of argc arguments returned.' 0 "${FLAGS_ARGC}"
}

testSingleNonFlagArg() {
  _testNonFlagArgs 1 argOne
}

testMultipleNonFlagArgs() {
  _testNonFlagArgs 3 argOne argTwo arg3
}

testMultipleNonFlagStringArgsWithSpaces()
{
  flags_getoptIsEnh || return
  _testNonFlagArgs 3 argOne 'arg two' arg3
}

testFlagsWithEquals()
{
  flags_getoptIsEnh || return

  FLAGS --str='str_flag' 'non_flag' >"${stdoutF}" 2>"${stderrF}"
  assertTrue 'FLAGS returned a non-zero result' $?
  assertEquals 'string flag not set properly' 'str_flag' "${FLAGS_str}"
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"

  eval set -- "${FLAGS_ARGV}"
  assertEquals 'wrong count of argv arguments returned.' 1 $#
  assertEquals 'wrong count of argc arguments returned.' 1 "${FLAGS_ARGC}"
}

testComplicatedCommandLineStandard() {
  flags_getoptIsEnh && return

  # Note: standard getopt stops parsing after first non-flag argument, which
  # results in the remaining flags being treated as arguments instead.
  FLAGS -i 1 non_flag_1 -s 'two' non_flag_2 -f 3 non_flag_3 \
      >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue 'FLAGS returned a non-zero result' ${r3turn}
  assertEquals 'failed int test' 1 "${FLAGS_int}"
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"

  eval set -- "${FLAGS_ARGV}"
  assertEquals 'incorrect number of argv values' 7 $#
}

testComplicatedCommandLineEnhanced() {
  flags_getoptIsEnh || return

  FLAGS -i 1 non_flag_1 --str='two' non_flag_2 --float 3 'non flag 3' \
      >"${stdoutF}" 2>"${stderrF}"
  r3turn=$?
  assertTrue 'FLAGS returned a non-zero result' ${r3turn}
  assertEquals 'failed int test' 1 "${FLAGS_int}"
  assertEquals 'failed str test' 'two' "${FLAGS_str}"
  assertEquals 'failed float test' 3 "${FLAGS_float}"
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"

  eval set -- "${FLAGS_ARGV}"
  assertEquals 'incorrect number of argv values' 3 $#
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
