#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# shFlags unit test for the flag definition methods

# load test helpers
. ./shflags_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testFlagsDefine()
{
  # TODO(kward): check for messages on STDERR
  # no arguments
  _flags_define 2>/dev/null
  assertFalse \
      '_flags_define() with no arguments should have failed.' \
      $?

  # one argument
  _flags_define arg1 2>/dev/null
  assertFalse \
      '_flags_define() with only one argument should have failed.' \
      $?

  # two arguments
  _flags_define arg1 arg2 2>/dev/null
  assertFalse \
      '_flags_define() with only two arguments should have failed.' \
      $?

  # three arguments
  _flags_define arg1 arg2 arg3 2>/dev/null
  assertFalse \
      '_flags_define() with only three arguments should have failed.' \
      $?

  # multiple definition -- assumes working boolean definition (tested elsewhere)
  _flags_define ${__FLAGS_TYPE_BOOLEAN} multiDefBool true 'multi def #1' m
  _flags_define ${__FLAGS_TYPE_BOOLEAN} multiDefBool false 'multi def #2' m
  rtrn=$?
  assertTrue \
      '_flags_define() should not overwrite previously defined default.' \
      "${FLAGS_multiDefBool:-}"
  assertFalse \
      '_flags_define() with existing flag name should fail' \
      ${rtrn}

  # TODO(kward): test requirement of enhanced getopt

  # invalid type
  # TODO(kward): check for message on STDERR
  _flags_define invalid arg2 arg3 arg4 >"${stdoutF}" 2>"${stderrF}"
  assertFalse \
      '_flags_define() with invalid "type" should have failed.' \
      $?
  assertNotNull 'expected output to STDERR' "`cat ${stderrF}`"
}

testBoolean()
{
  # test true defaults
  for default in 'true' 't' 0; do
    flags_reset
    DEFINE_boolean boolVal "${default}" 'my boolean' b
    rtrn=$?
    assertTrue \
        "DEFINE_boolean() call with default of \"${default}\" failed." \
        "${FLAGS_boolVal:-}"
    assertTrue \
        "DEFINE_boolean() call with default of \"${default}\" returned faliure." \
        ${rtrn}
  done

  # test false defaults
  for default in 'false' 'f' 1; do
    flags_reset
    DEFINE_boolean boolVal "${default}" 'my boolean' b
    rtrn=$?
    assertFalse \
        "DEFINE_boolean() call with default of \"${default}\" failed." \
        "${FLAGS_boolVal:-}"
    assertTrue \
        "DEFINE_boolean() call with default of \"${default}\" returned faliure." \
        ${rtrn}
  done

  # test invalid default
  flags_reset
  DEFINE_boolean boolVal 'invalid' 'my boolean' b >"${stdoutF}" 2>"${stderrF}"
  assertFalse \
      'DEFINE_boolean() call with invalid default did not fail.' \
      $?
  assertNotNull 'expected output to STDERR' "`cat ${stderrF}`"
}

testFloat()
{
  # test valid defaults
  for default in -1234.56789 -1.0 0.0 1.0 1234.56789; do
    flags_reset
    DEFINE_float floatVal ${default} "float: ${default}" f
    rtrn=$?
    assertSame \
        "DEFINE_float() call with valid default failed." \
        ${default} "${FLAGS_floatVal:-}"
    assertTrue \
        "DEFINE_float() call with valid default of \"${default}\" returned faliure." \
        ${rtrn}
  done

  # test invalid defaults
  flags_reset
  DEFINE_float floatVal 'invalid' 'invalid float: string' f \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse \
      'DEFINE_float() call with string value default did not fail.' \
      $?
  assertErrorMsg
}

testInteger()
{
  # test valid defaults
  for default in -123456789 -1 0 1 123456789; do
    flags_reset
    DEFINE_integer intVal ${default} "integer: ${default}" i
    rtrn=$?
    assertSame \
        "DEFINE_integer() call with valid default failed." \
        ${default} "${FLAGS_intVal:-}"
    assertTrue \
        "DEFINE_integer() call with valid default of \"${default}\" returned faliure." \
        ${rtrn}
  done

  # test invalid defaults
  flags_reset
  DEFINE_integer intVal 1.234 'invalid integer: float' i \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse \
      'DEFINE_integer() call with float value default did not fail.' \
      $?
  assertErrorMsg 'float default'

  DEFINE_integer intVal -1.234 'invalid integer: negative float' i \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse \
      'DEFINE_integer() call with negative float value default did not fail.' \
      $?
  assertErrorMsg 'negative float default'

  DEFINE_integer intVal 'invalid' 'invalid integer: string' i \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse \
      'DEFINE_integer() call with string value default did not fail.' \
      $?
  assertErrorMsg 'string default'
}

testString()
{
  # test valid defaults
  for default in -1234.56789 -1.0 0.0 1.0 1234.56789 valid 'also valid'; do
    flags_reset
    DEFINE_string strVal "${default}" "string: ${default}" s
    rtrn=$?
    assertSame \
        "DEFINE_string() call with valid default failed." \
        "${default}" "${FLAGS_strVal:-}"
    assertTrue \
        "DEFINE_string() call with valid default of \"${default}\" returned faliure." \
        ${rtrn}
  done

  # test "empty" strings
  flags_reset
  DEFINE_string str '' "string: empty single quotes" s
  rtrn=$?
  assertSame \
      "DEFINE_string() call with valid default failed." \
      "" "${FLAGS_str:-}"
}

testShortNameLength()
{
  # make sure short names are no longer than a single character
  :
}

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
}

setUp()
{
  flags_reset
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
