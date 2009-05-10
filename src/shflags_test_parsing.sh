#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# shFlags unit test for the flag definition methods
#
# TODO(kward): assert on FLAGS errors
# TODO(kward): testNonStandardIFS()

# load test helpers
. ./shflags_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testGetoptStandard()
{
  _flags_getoptStandard '-b' >"${stdoutF}" 2>"${stderrF}"
  rslt=$?
  assertTrue "didn't parse valid flag 'b'" ${rslt}
  th_showOutput ${rslt} "${stdoutF}" "${stderrF}"

  _flags_getoptStandard '-x' >"${stdoutF}" 2>"${stderrF}"
  assertFalse "parsed invalid flag 'x'" $?
}

testGetoptEnhanced()
{
  flags_getoptIsEnh || startSkipping

  _flags_getoptEnhanced '-b' >"${stdoutF}" 2>"${stderrF}"
  assertTrue "didn't parse valid flag 'b'" $?
  _flags_getoptEnhanced '--bool' >"${stdoutF}" 2>"${stderrF}"
  assertTrue "didn't parse valid flag 'bool'" $?

  _flags_getoptEnhanced '-x' >"${stdoutF}" 2>"${stderrF}"
  assertFalse "parsed invalid flag 'x'" $?
  _flags_getoptEnhanced '--xyz' >"${stdoutF}" 2>"${stderrF}"
  assertFalse "parsed invalid flag 'xyz'" $?
}

testValidBooleanShort()
{
  # flip flag to true
  FLAGS -b >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue "FLAGS returned a non-zero result (${rtrn})" ${rtrn}
  value=${FLAGS_bool:-}
  assertTrue "boolean was not true (${value})." "${value}"
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  test ${rtrn} -eq ${FLAGS_TRUE} -a ! -s "${stderrF}"
  th_showOutput $? "${stdoutF}" "${stderrF}"

  # verify that passing the option a second time leaves the flag true
  FLAGS -b >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue "repeat: FLAGS returned a non-zero result (${rtrn})" ${rtrn}
  value=${FLAGS_bool:-}
  assertTrue "repeat: boolean was not true (${value})" ${value}
  assertFalse 'repeat: expected no output to STDERR' "[ -s '${stderrF}' ]"
  test ${rtrn} -eq ${FLAGS_TRUE} -a ! -s "${stderrF}"
  th_showOutput $? "${stdoutF}" "${stderrF}"
}

testValidBooleanLong()
{
  flags_getoptIsEnh || startSkipping

  # note: the default value of bool is 'false'

  # leave flag false
  FLAGS --nobool >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue "FLAGS returned a non-zero result (${rtrn})" ${rtrn}
  assertFalse '--noXX flag resulted in true value.' ${FLAGS_bool:-}
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"

  # flip flag true
  FLAGS --bool >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue "FLAGS returned a non-zero result (${rtrn})" ${rtrn}
  assertTrue '--XX flag resulted in false value.' ${FLAGS_bool:-}
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"

  # flip flag back false
  FLAGS --nobool >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue "FLAGS returned a non-zero result (${rtrn})" ${rtrn}
  assertFalse '--noXX flag resulted in true value.' ${FLAGS_bool:-}
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
}

testValidFloats()
{
  _testValidFloats '-f'
  flags_getoptIsEnh || startSkipping
  _testValidFloats '--float'
}

_testValidFloats()
{
  flag=$1
  for value in ${TH_FLOAT_VALID}; do
    FLAGS ${flag} ${value} >"${stdoutF}" 2>"${stderrF}"
    rtrn=$?
    assertTrue "FLAGS (${value}) returned a non-zero result (${rtrn})" ${rtrn}
    assertEquals "float (${value}) test failed." ${value} ${FLAGS_float}
    assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
    th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
  done
}

testInvalidFloats()
{
  _testInvalidFloats '-f'
  flags_getoptIsEnh || startSkipping
  _testInvalidFloats '--float'
}

_testInvalidFloats()
{
  flag=$1
  for value in ${TH_FLOAT_INVALID}; do
    FLAGS ${flag} ${value} >"${stdoutF}" 2>"${stderrF}"
    rtrn=$?
    assertFalse "FLAGS (${value}) returned a zero result" ${rtrn}
    assertTrue 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  done
}

testValidIntegers()
{
  _testValidIntegers '-i'
  flags_getoptIsEnh || startSkipping
  _testValidIntegers '--int'
}

_testValidIntegers()
{
  flag=$1
  for value in ${TH_INT_VALID}; do
    FLAGS ${flag} ${value} >"${stdoutF}" 2>"${stderrF}"
    rtrn=$?
    assertTrue "FLAGS (${value}) returned a non-zero result (${rtrn})" ${rtrn}
    assertEquals "integer (${value}) test failed." ${value} ${FLAGS_int}
    assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
    th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
  done
}

testInvalidIntegers()
{
  _testInvalidIntegers '-i'
  flags_getoptIsEnh || startSkipping
  _testInvalidIntegers '--int'
}

_testInvalidIntegers()
{
  flag=$1
  for value in ${TH_INT_INVALID}; do
    FLAGS ${flag} ${value} >"${stdoutF}" 2>"${stderrF}"
    rtrn=$?
    assertFalse "invalid integer (${value}) test returned success." ${rtrn}
    assertTrue 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  done
}

testValidStrings()
{
  _testValidStrings -s single_word
  flags_getoptIsEnh || startSkipping
  _testValidStrings --str single_word
  _testValidStrings --str 'string with spaces'
}

_testValidStrings()
{
  flag=$1
  value=$2

  FLAGS ${flag} "${value}" >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue "'FLAGS ${flag} ${value}' returned a non-zero result (${rtrn})" \
      ${rtrn}
  assertEquals "string (${value}) test failed." "${value}" "${FLAGS_str}"
  if [ ${rtrn} -eq ${FLAGS_TRUE} ]; then
    assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  else
    # validate that an error is thrown for unsupported getopt uses
    assertFatalMsg '.* spaces in options'
  fi
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
}

testMultipleFlags()
{
  _testMultipleFlags '-b' '-i' '-f' '-s'
  flags_getoptIsEnh || startSkipping
  _testMultipleFlags '--bool' '--int' '--float' '--str'
}

_testMultipleFlags()
{
  boolFlag=$1
  intFlag=$2
  floatFlag=$3
  strFlag=$4

  FLAGS \
      ${boolFlag} \
      ${intFlag} 567 \
      ${floatFlag} 123.45678 \
      ${strFlag} 'some_string' \
      >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue "use of multple flags returned a non-zero result" ${rtrn}
  assertTrue 'boolean test failed.' ${FLAGS_bool}
  assertNotSame 'float test failed.' 0 ${FLAGS_float}
  assertNotSame 'integer test failed.' 0 ${FLAGS_int}
  assertNotSame 'string test failed.' '' ${FLAGS_str}
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
}

_testNonFlagArgs()
{
  argc=$1
  shift

  FLAGS "$@" >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue 'parse returned non-zero value.' ${rtrn}
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"

  eval set -- "${FLAGS_ARGV}"
  assertEquals 'wrong count of argv arguments returned.' ${argc} $#
  assertEquals 'wrong count of argc arguments returned.' 0 ${FLAGS_ARGC}
}

testSingleNonFlagArg()
{
  _testNonFlagArgs 1 argOne
}

testMultipleNonFlagArgs()
{
  _testNonFlagArgs 3 argOne argTwo arg3
}

testMultipleNonFlagStringArgsWithSpaces()
{
  flags_getoptIsEnh || startSkipping
  _testNonFlagArgs 3 argOne 'arg two' arg3
}

testFlagsWithEquals()
{
  flags_getoptIsEnh || startSkipping

  FLAGS --str='str_flag' 'non_flag' >"${stdoutF}" 2>"${stderrF}"
  assertTrue 'FLAGS returned a non-zero result' $?
  assertEquals 'string flag not set properly' 'str_flag' "${FLAGS_str}"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"

  eval set -- "${FLAGS_ARGV}"
  assertEquals 'wrong count of argv arguments returned.' 1 $#
  assertEquals 'wrong count of argc arguments returned.' 1 ${FLAGS_ARGC}
}

testComplicatedCommandLineStandard()
{
  flags_getoptIsStd || startSkipping

  # note: standard getopt stops parsing after first non-flag argument :-(
  FLAGS -i 1 non_flag_1 -s 'two' non_flag_2 -f 3 non_flag_3 \
      >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue 'FLAGS returned a non-zero result' ${rtrn}
  assertEquals 'failed int test' 1 ${FLAGS_int}
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"

  eval set -- "${FLAGS_ARGV}"
  assertEquals 'incorrect number of argv values' 7 $#
}

testComplicatedCommandLineEnhanced()
{
  flags_getoptIsEnh || startSkipping

  FLAGS -i 1 non_flag_1 --str='two' non_flag_2 --float 3 'non flag 3' \
      >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue 'FLAGS returned a non-zero result' ${rtrn}
  assertEquals 'failed int test' 1 ${FLAGS_int}
  assertEquals 'failed str test' 'two' "${FLAGS_str}"
  assertEquals 'failed float test' 3 ${FLAGS_float}
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"

  eval set -- "${FLAGS_ARGV}"
  assertEquals 'incorrect number of argv values' 3 $#
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  th_oneTimeSetUp

  if flags_getoptIsStd; then
    th_warn 'Standard version of getopt found. Enhanced tests will be skipped.'
  else
    th_warn 'Enhanced version of getopt found. Standard tests will be skipped.'
  fi
}

setUp()
{
  flags_reset
  DEFINE_boolean bool false 'boolean value' b
  DEFINE_float float 0.0 'float test' 'f'
  DEFINE_integer int 0 'integer test' 'i'
  DEFINE_string str '' 'string test' 's'
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
