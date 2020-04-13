#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# shFlags unit test for the flag definition methods
#
# Copyright 2008-2020 Kate Ward. All Rights Reserved.
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

# These variables will be overridden by the test helpers.
stdoutF="${TMPDIR:-/tmp}/STDOUT"
stderrF="${TMPDIR:-/tmp}/STDERR"

# Load test helpers.
. ./shflags_test_helpers

testGetoptStandard() {
  if ! _flags_getoptStandard '-b' >"${stdoutF}" 2>"${stderrF}"; then
    fail "error parsing -b flag"
    _showTestOutput
  fi

  if _flags_getoptStandard '-x' >"${stdoutF}" 2>"${stderrF}"; then
    fail "expected error parsing invalid -x flag"
    _showTestOutput
  fi
}

testGetoptEnhanced() {
  if ! flags_getoptIsEnh; then
    return
  fi

  if ! _flags_getoptEnhanced '-b' >"${stdoutF}" 2>"${stderrF}"; then
    fail "error parsing -b flag"
    _showTestOutput
  fi
  if ! _flags_getoptEnhanced '--bool' >"${stdoutF}" 2>"${stderrF}"; then
    fail "error parsing --bool flag"
    _showTestOutput
  fi

  if _flags_getoptEnhanced '-x' >"${stdoutF}" 2>"${stderrF}"; then
    fail "expected error parsing invalid -x flag"
    _showTestOutput
  fi
  if _flags_getoptEnhanced '--xyz' >"${stdoutF}" 2>"${stderrF}"; then
    fail "expected error parsing invalid --xyz flag"
    _showTestOutput
  fi
}

testValidBoolsShort() {
  desc='bool_true_arg'
  if FLAGS -b >"${stdoutF}" 2>"${stderrF}"; then
    assertTrue "${desc}: expected true value" "${FLAGS_bool:-}"
  else
    fail "${desc}: FLAGS returned a non-zero result ($?)"
  fi
  th_showOutput

  desc='bool2_defined'
  DEFINE_boolean bool2 true '2nd boolean' B
  if FLAGS >"${stdoutF}" 2>"${stderrF}"; then
    assertTrue "${desc}: expected true value" "${FLAGS_bool2:-}"
  else
    fail "${desc}: FLAGS returned a non-zero result ($?)"
  fi
  th_showOutput

  desc='bool_false_arg'
  if FLAGS -B >"${stdoutF}" 2>"${stderrF}"; then
    assertFalse "${desc}: expected false value" "${FLAGS_bool2:-}"
  else
    fail "${desc}: FLAGS returned a non-zero result ($?)"
  fi
  th_showOutput
}

# TODO(kate): separate into multiple functions to reflect correct usage
testValidBoolsLong() {
  flags_getoptIsEnh
  [ $? -eq "${FLAGS_FALSE}" ] && return

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

testFloats() {
  _testFloats '-f'
  if flags_getoptIsEnh; then
    _testFloats '--float'
  fi
}

_testFloats() {
  flag=$1

  for value in ${TH_FLOAT_VALID}; do
    if FLAGS "${flag}" "${value}" >"${stdoutF}" 2>"${stderrF}"; then
      # shellcheck disable=SC2154
      assertEquals "${flag}: incorrect value" "${value}" "${FLAGS_float}"
    else
      fail "${flag}: unexpected non-zero result ($?)"
      th_showOutput
    fi
  done

  for value in ${TH_FLOAT_INVALID}; do
    # Wrap FLAGS in () to catch errors.
    if (FLAGS "${flag}" "${value}" >"${stdoutF}" 2>"${stderrF}"); then
      fail "${flag}: expected a non-zero result"
      th_showOutput
    else
      assertEquals "${flag}: expected an error" $? "${FLAGS_ERROR}"
    fi
  done
}

testIntegers() {
  _testIntegers '-i'
  if flags_getoptIsEnh; then
    _testIntegers '--int'
  fi
}

_testIntegers() {
  flag=$1

  for value in ${TH_INT_VALID}; do
    if FLAGS "${flag}" "${value}" >"${stdoutF}" 2>"${stderrF}"; then
      # shellcheck disable=SC2154
      assertEquals "${flag}: incorrect value" "${value}" "${FLAGS_int}"
    else
      fail "${flag}: unexpected non-zero result ($?)"
      th_showOutput
    fi
  done

  for value in ${TH_INT_INVALID}; do
    # Wrap FLAGS in () to catch errors.
    if (FLAGS "${flag}" "${value}" >"${stdoutF}" 2>"${stderrF}"); then
      fail "${flag}: expected a non-zero result"
      th_showOutput
    else
      assertEquals "${flag}: expected an error" $? "${FLAGS_ERROR}"
    fi
  done
}

testStrings() {
  _testStrings 'std_single_word' -s single_word
  if flags_getoptIsEnh; then
    _testStrings 'enh_single_word' --str single_word
    _testStrings 'enh_multi_word'  --str 'string with spaces'
  fi
}

_testStrings() {
  desc=$1
  flag=$2
  value=$3

  if FLAGS "${flag}" "${value}" >"${stdoutF}" 2>"${stderrF}"; then
    # shellcheck disable=SC2154
    assertEquals "${desc}: incorrect value" "${value}" "${FLAGS_str}"
  else
    fail "${desc}: unexpected non-zero result ($?)"
    # Validate that an error is thrown for unsupported getopt uses.
    assertFatalMsg '.* spaces in options'
    th_showOutput
  fi
}

testMultipleFlags() {
  _testMultipleFlags '-b' '-i' '-f' '-s'
  flags_getoptIsEnh
  [ $? -eq "${FLAGS_FALSE}" ] && return
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
}

testSingleNonFlagArg()    { _testNonFlagArgs 1 argOne; }
testMultipleNonFlagArgs() { _testNonFlagArgs 3 argOne argTwo arg3; }

testMultipleNonFlagStringArgsWithSpaces() {
  if flags_getoptIsEnh; then
    _testNonFlagArgs 3 argOne 'arg two' arg3
  fi
}

testFlagsWithEquals() {
  if ! flags_getoptIsEnh; then
    return
  fi

  FLAGS --str='str_flag' 'non_flag' >"${stdoutF}" 2>"${stderrF}"
  assertTrue 'FLAGS returned a non-zero result' $?
  assertEquals 'string flag not set properly' 'str_flag' "${FLAGS_str}"
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"

  eval set -- "${FLAGS_ARGV}"
  assertEquals 'wrong count of argv arguments returned.' 1 $#
}

testComplicatedCommandLineStandard() {
  flags_getoptIsEnh
  [ $? -eq "${FLAGS_TRUE}" ] && return

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
  flags_getoptIsEnh
  [ $? -eq "${FLAGS_FALSE}" ] && return

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

# showTestOutput for the most recently run test.
_showTestOutput() { th_showOutput "${SHUNIT_FALSE}" "${stdoutF}" "${stderrF}"; }

# Load and run shUnit2.
# shellcheck disable=SC2034
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. "${TH_SHUNIT}"
