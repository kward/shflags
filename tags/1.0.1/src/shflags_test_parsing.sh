#! /bin/sh
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

# load test helpers
. ./shflags_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testValidBooleanShort()
{
  DEFINE_boolean bool false 'boolean value' b

  # flip flag to true
  FLAGS -b >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue 'FLAGS returned a non-zero result' ${rtrn}
  assertTrue 'boolean was false.' ${FLAGS_bool:-}
  assertFalse 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"

  # verify that passing the option a second time leaves the flag true
  FLAGS -b >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue 'FLAGS returned a non-zero result' ${rtrn}
  assertTrue 'boolean was false.' ${FLAGS_bool:-}
  assertFalse 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
}

testValidBooleanLong()
{
  flags_getoptIsStd && startSkipping

  DEFINE_boolean bool false 'boolean test' 'b'

  # leave flag false
  FLAGS --nobool >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue 'FLAGS returned a non-zero result' ${rtrn}
  assertFalse '--noXX flag resulted in true value.' ${FLAGS_bool:-}
  assertFalse 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"

  # flip flag true
  FLAGS --bool >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue 'FLAGS returned a non-zero result' ${rtrn}
  assertTrue '--XX flag resulted in false value.' ${FLAGS_bool:-}
  assertFalse 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"

  # flip flag back false
  FLAGS --nobool >"${stdoutF}" 2>"${stderrF}"
  rtrn=$?
  assertTrue 'FLAGS returned a non-zero result' ${rtrn}
  assertFalse '--noXX flag resulted in true value.' ${FLAGS_bool:-}
  assertFalse 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
}

testValidFloats()
{
  _testValidFloats '-f'
  flags_getoptIsStd && startSkipping
  _testValidFloats '--float'
}

_testValidFloats()
{
  flag=$1
  for value in ${TH_FLOAT_VALID}; do
    flags_reset
    DEFINE_float float 0 'float test' 'f'
    FLAGS ${flag} ${value} >"${stdoutF}" 2>"${stderrF}"
    rtrn=$?
    assertTrue "FLAGS (${value}) returned a non-zero result" ${rtrn}
    assertEquals "float (${value}) test failed." ${value} ${FLAGS_float}
    assertFalse 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
    th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
  done
}

testInvalidFloats()
{
  _testInvalidFloats '-f'
  flags_getoptIsStd && startSkipping
  _testInvalidFloats '--float'
}

_testInvalidFloats()
{
  flag=$1
  for value in ${TH_FLOAT_INVALID}; do
    flags_reset
    DEFINE_float float 0 'float test' 'f'
    FLAGS ${flag} ${value} >"${stdoutF}" 2>"${stderrF}"
    rtrn=$?
    assertFalse "FLAGS (${value}) returned a zero result" ${rtrn}
    assertTrue 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
  done
}

testValidIntegers()
{
  _testValidIntegers '-i'
  flags_getoptIsStd && startSkipping
  _testValidIntegers '--int'
}

_testValidIntegers()
{
  flag=$1
  for value in ${TH_INT_VALID}; do
    flags_reset
    DEFINE_integer int 0 'integer test' 'i'
    FLAGS ${flag} ${value} >"${stdoutF}" 2>"${stderrF}"
    rtrn=$?
    assertTrue "FLAGS (${value}) returned a non-zero result" ${rtrn}
    assertEquals "integer (${value}) test failed." ${value} ${FLAGS_int}
    assertFalse 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
    th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
  done
}

testInvalidIntegers()
{
  _testInvalidIntegers '-i'
  flags_getoptIsStd && startSkipping
  _testInvalidIntegers '--int'
}

_testInvalidIntegers()
{
  flag=$1
  for value in ${TH_INT_INVALID}; do
    flags_reset
    DEFINE_integer int 0 'integer test' 'i'
    FLAGS ${flag} ${value} >"${stdoutF}" 2>"${stderrF}"
    rtrn=$?
    assertFalse "invalid integer (${value}) test returned success." ${rtrn}
    assertTrue 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
  done
}

testValidStrings()
{
  _testValidStrings '-s'
  flags_getoptIsStd && startSkipping
  _testValidStrings '--str'
}

_testValidStrings()
{
  flag=$1
  for value in single_word 'string with spaces'; do
    flags_reset
    DEFINE_string str '' 'string test' 's'
    FLAGS ${flag} "${value}" >"${stdoutF}" 2>"${stderrF}"
    rtrn=$?
    assertTrue "FLAGS (${value}) returned a non-zero result" ${rtrn}
    assertEquals "string (${value}) test failed." "${value}" "${FLAGS_str}"
    th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
    if [ ${rtrn} -eq ${FLAGS_TRUE} ]; then
      assertFalse 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
    else
      # validate that an error is thrown for unsupported getopt uses
      assertErrorMsg "${value}"
    fi
  done
}

testMultipleFlags()
{
  _testMultipleFlags '-b' '-i' '-f' '-s'
  flags_getoptIsStd && startSkipping
  _testMultipleFlags '--bool' '--int' '--float' '--str'
}

_testMultipleFlags()
{
  boolFlag=$1
  intFlag=$2
  floatFlag=$3
  strFlag=$4

  flags_reset
  DEFINE_boolean bool false 'a boolean' 'b'
  DEFINE_integer int 0 'a integer' 'i'
  DEFINE_float float 0 'a float' 'f'
  DEFINE_string str '' 'a string' 's'
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
  assertFalse 'expected no output to STDERR' "[ -s \"${stderrF}\" ]"
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
}

_testNonFlagArgs()
{
  argc=$1
  shift

  FLAGS $@
  assertTrue 'parse returned value.' $?

  # shift out the parsed arguments to reach those that weren't parsed
  shift ${FLAGS_ARGC}
  assertSame 'wrong argc value.' ${argc} $#
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
  _testNonFlagArgs 3 argOne 'arg #2' arg3
}

# TODO(kward): testNonstandardIFS()

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  # load flags
  [ -n "${ZSH_VERSION:-}" ] && FLAGS_PARENT=$0
  . ${TH_SHFLAGS}

  tmpDir="${__shunit_tmpDir}/output"
  mkdir "${tmpDir}"
  stdoutF="${tmpDir}/stdout"
  stderrF="${tmpDir}/stderr"

  if [ ${__FLAGS_GETOPT_VERS} -eq ${__FLAGS_GETOPT_VERS_STD} ]; then
    th_warn 'Standard version of getopt found. Some tests will be skipped.'
  fi
}

setUp()
{
  flags_reset
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
