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

# Exit immediately if a simple command exits with a non-zero status.
#set -e

# These variables will be overridden by the test helpers.
stdoutF="${TMPDIR:-/tmp}/STDOUT"
stderrF="${TMPDIR:-/tmp}/STDERR"

# Load test helpers.
. ./shflags_test_helpers

testFlagsDefine() {
  # No arguments.
  _flags_define >"${stdoutF}" 2>"${stderrF}"
  assertFalse '_flags_define() with no arguments should have failed.' $?
  assertErrorMsg '' 'no arguments'

  # One argument.
  _flags_define arg1 >"${stdoutF}" 2>"${stderrF}"
  assertFalse '_flags_define() call with one argument should fail' $?
  assertErrorMsg '' 'one argument'

  # Two arguments.
  _flags_define arg1 arg2 >"${stdoutF}" 2>"${stderrF}"
  assertFalse '_flags_define() call with two arguments should fail' $?
  assertErrorMsg '' 'two arguments'

  # Three arguments.
  _flags_define arg1 arg2 arg3 >"${stdoutF}" 2>"${stderrF}"
  assertFalse '_flags_define() call with three arguments should fail' $?
  assertErrorMsg '' 'three arguments'

  # Multiple definition. Assumes working boolean definition (tested elsewhere).
  _flags_define "${__FLAGS_TYPE_BOOLEAN}" multiDefBool true 'multi def #1' m
  _flags_define "${__FLAGS_TYPE_BOOLEAN}" multiDefBool false 'multi def #2' m \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse '_flags_define() with existing flag name should fail' $?
  assertTrue \
      '_flags_define() should not overwrite previously defined default.' \
      "${FLAGS_multiDefBool:-}"
  assertWarnMsg '' 'existing flag'

  # Duplicate dashed and underscored definition.
  _flags_define "${__FLAGS_TYPE_STRING}" long-name 'foo' 'dashed name' l
  _flags_define "${__FLAGS_TYPE_STRING}" long_name 'bar' 'underscored name' l \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse '_flags_define() with existing flag name should fail' $?
  # shellcheck disable=SC2154
  assertEquals \
      '_flags_define() should not overwrite previously defined default.' \
      "${FLAGS_long_name}" 'foo'
  assertWarnMsg '' 'already exists'

  # TODO(kward): test requirement of enhanced getopt.

  # Invalid type.
  _flags_define invalid arg2 arg3 arg4 i >"${stdoutF}" 2>"${stderrF}"
  assertFalse '_flags_define() with "invalid" type should have failed.' $?
  assertErrorMsg 'unrecognized flag type' 'invalid type'
}

testBoolean() {
  # Test true defaults.
  for default in 'true' 't' 0; do
    flags_reset
    DEFINE_boolean boolVal "${default}" 'my boolean' b
    rtrn=$?
    assertTrue \
        "DEFINE_boolean() call with default of '${default}' failed." \
        "${FLAGS_boolVal:-}"
    assertTrue \
        "DEFINE_boolean() call with default of '${default}' returned failure." \
        ${rtrn}
  done

  # test false defaults
  for default in 'false' 'f' 1; do
    flags_reset
    DEFINE_boolean boolVal "${default}" 'my boolean' b
    rtrn=$?
    assertFalse \
        "DEFINE_boolean() call with default of '${default}' failed." \
        "${FLAGS_boolVal:-}"
    assertTrue \
        "DEFINE_boolean() call with default of '${default}' returned failure." \
        ${rtrn}
  done

  # Test invalid default.
  flags_reset
  DEFINE_boolean boolVal 'invalid' 'my boolean' b >"${stdoutF}" 2>"${stderrF}"
  assertFalse 'DEFINE_boolean() call with invalid default did not fail.' $?
  assertErrorMsg
}

testFloat() {
  # Test valid defaults.
  for default in ${TH_FLOAT_VALID}; do
    flags_reset
    DEFINE_float floatVal "${default}" "float: ${default}" f
    rtrn=$?
    assertSame "DEFINE_float() call with valid default failed." \
        "${default}" "${FLAGS_floatVal:-}"
    assertTrue \
        "DEFINE_float() call with valid default of '${default}' returned failure." \
        ${rtrn}
  done

  # Test invalid defaults.
  flags_reset
  DEFINE_float floatVal 'invalid' 'invalid float: string' f \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse 'DEFINE_float() call with string value default did not fail.' $?
  assertErrorMsg
}

testInteger() {
  # Test valid defaults.
  for default in ${TH_INT_VALID}; do
    flags_reset
    DEFINE_integer intVal "${default}" "integer: ${default}" i
    rtrn=$?
    assertSame \
        "DEFINE_integer() call with valid default failed." \
        "${default}" "${FLAGS_intVal:-}"
    assertTrue \
        "DEFINE_integer() call with valid default of '${default}' returned failure." \
        ${rtrn}
  done

  # Test invalid defaults.
  flags_reset
  DEFINE_integer intVal 1.234 'invalid integer: float' i \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse 'DEFINE_integer() call with float value default did not fail.' $?
  assertErrorMsg 'invalid default' 'float default'

  DEFINE_integer intVal -1.234 'invalid integer: negative float' i \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse \
      'DEFINE_integer() call with negative float value default did not fail.' \
      $?
  assertErrorMsg 'invalid default' 'negative float default'

  DEFINE_integer intVal 'invalid' 'invalid integer: string' i \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse \
      'DEFINE_integer() call with string value default did not fail.' \
      $?
  assertErrorMsg 'invalid default' 'string default'
}

testString()
{
  # test valid defaults
  for default in \
      ${TH_BOOL_VALID} \
      ${TH_FLOAT_VALID} \
      ${TH_INT_VALID} \
      'also valid'
  do
    flags_reset
    DEFINE_string strVal "${default}" "string: ${default}" s
    rtrn=$?
    assertSame \
        "DEFINE_string() call with valid default failed." \
        "${default}" "${FLAGS_strVal:-}"
    assertTrue \
        "DEFINE_string() call with valid default of '${default}' returned failure." \
        ${rtrn}
  done

  # test "empty" strings
  flags_reset
  DEFINE_string str '' "string: empty single quotes" s
  rtrn=$?
  assertSame \
      "DEFINE_string() call with valid default failed." \
      '' "${FLAGS_str:-}"
}

testShortNameLength() {
  # Make sure short names are no longer than a single character.
  :
}

testFlagNameIsReserved() {
  ( DEFINE_string TRUE '' 'true is a reserved flag name' t \
      >"${stdoutF}" 2>"${stderrF}" )
  rtrn=$?
  assertEquals "${FLAGS_ERROR}" "${rtrn}"
  assertErrorMsg 'flag name (TRUE) is reserved'
}

oneTimeSetUp() {
  th_oneTimeSetUp
}

tearDown() {
  flags_reset
}

# Load and run shUnit2.
# shellcheck disable=SC2034
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. "${TH_SHUNIT}"
