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

# Exit immediately if a simple command exits with a non-zero status.
set -e

# Treat unset variables as an error when performing parameter expansion.
set -u

# These variables will be overridden by the test helpers.
stdoutF="${TMPDIR:-/tmp}/STDOUT"
stderrF="${TMPDIR:-/tmp}/STDERR"

# Load test helpers.
. ./shflags_test_helpers

testFlagsDefine() {
  # No arguments.
  if _flags_define >"${stdoutF}" 2>"${stderrF}"
  then :; else
    assertEquals '_flags_define() with no arguments should error' "${FLAGS_ERROR}" $?
  fi
  assertErrorMsg '' 'no arguments'

  # One argument.
  if _flags_define arg1 >"${stdoutF}" 2>"${stderrF}"
  then :; else
    assertEquals '_flags_define() call with one argument should error' "${FLAGS_ERROR}" $?
  fi
  assertErrorMsg '' 'one argument'

  # Two arguments.
  if _flags_define arg1 arg2 >"${stdoutF}" 2>"${stderrF}"
  then :; else
    assertEquals '_flags_define() call with two arguments should error' "${FLAGS_ERROR}" $?
  fi
  assertErrorMsg '' 'two arguments'

  # Three arguments.
  if _flags_define arg1 arg2 arg3 >"${stdoutF}" 2>"${stderrF}"
  then :; else
    assertEquals '_flags_define() call with three arguments should error' "${FLAGS_ERROR}" $?
  fi
  assertErrorMsg '' 'three arguments'

  # Multiple definition. Assumes working boolean definition (tested elsewhere).
  if ! _flags_define "${__FLAGS_TYPE_BOOLEAN}" multiDefBool true 'multi def #1' m; then
    fail "didn't expect _flags_define for 'multi def #1' to fail"
  fi
  if _flags_define "${__FLAGS_TYPE_BOOLEAN}" multiDefBool false 'multi def #2' m >"${stdoutF}" 2>"${stderrF}"
  then :; else
    assertEquals '_flags_define() with existing flag name should fail' "${FLAGS_FALSE}" $?
  fi
  assertTrue '_flags_define() should not overwrite previously defined default.' "${FLAGS_multiDefBool:-}"
  assertWarnMsg '' 'existing flag'

  # Duplicate dashed and underscored definition.
  if ! _flags_define "${__FLAGS_TYPE_STRING}" long-name 'foo' 'dashed name' l; then
    fail "didn't expect _flags_define() for 'dashed name' to fail"
  fi
  if _flags_define "${__FLAGS_TYPE_STRING}" long_name 'bar' 'underscored name' l >"${stdoutF}" 2>"${stderrF}"
  then :; else
    assertEquals '_flags_define() with duplicate dashed and underscored definition should fail' "${FLAGS_FALSE}" $?
  fi
  # shellcheck disable=SC2154
  assertEquals '_flags_define() should not overwrite previously defined default.' "${FLAGS_long_name}" 'foo'
  assertWarnMsg '' 'already exists'

  # TODO(kward): test requirement of enhanced getopt.

  # Invalid type.
  if _flags_define invalid arg2 arg3 arg4 i >"${stdoutF}" 2>"${stderrF}"
  then :; else
    assertEquals '_flags_define() with "invalid" type should have failed.' "${FLAGS_ERROR}" $?
  fi
  assertErrorMsg 'unrecognized flag type' 'invalid type'
}

testBoolean() {
  while read -r desc ok default want; do
    flags_reset

    if DEFINE_boolean boolVal "${default}" 'my boolean' b >"${stdoutF}" 2>"${stderrF}"
    then
      assertEquals "${desc}: incorrect FLAGS_boolVal value" "${FLAGS_boolVal:-}" "${want}"
    else
      got=$?
      if [ "${ok}" -eq "${FLAGS_TRUE}" ]; then
        assertEquals "${desc}: DEFINE_boolean() failed unexpectedly" "${want}" "${got}"
      else
        assertEquals "${desc}: DEFINE_boolean() expected different return value" "${want}" "${got}"
        assertErrorMsg
      fi
    fi
  done <<EOF
true_long   ${FLAGS_TRUE}  true    ${FLAGS_TRUE}
true_short  ${FLAGS_TRUE}  t       ${FLAGS_TRUE}
true_int    ${FLAGS_TRUE}  0       ${FLAGS_TRUE}
false_long  ${FLAGS_TRUE}  false   ${FLAGS_FALSE}
false_short ${FLAGS_TRUE}  f       ${FLAGS_FALSE}
false_int   ${FLAGS_TRUE}  1       ${FLAGS_FALSE}
invalid     ${FLAGS_FALSE} invalid ${FLAGS_ERROR}
EOF
}

testFloat() {
  # Valid defaults.
  for default in ${TH_FLOAT_VALID}; do
    flags_reset
    desc="valid_float_val='${default}'"
    if DEFINE_float floatVal "${default}" 'valid float' f
    then
      got="${FLAGS_floatVal:-}" want="${default}"
      assertEquals "${desc}: incorrect FLAGS_floatVal value" "${want}" "${got}"
    else
      assertEquals "${desc}: DEFINE_float() failed unexpectedly." "${FLAGS_TRUE}" $?
    fi
  done

  # Invalid defaults.
  for default in ${TH_FLOAT_INVALID}; do
    flags_reset
    desc="invalid_float_val='${default}'"
    if DEFINE_float floatVal "${default}" 'invalid float' f >"${stdoutF}" 2>"${stderrF}"
    then
      fail "${desc}: expected DEFINE_float() to fail"
    else
      assertEquals "${desc}: DEFINE_float() expected error" "${FLAGS_ERROR}" $?
      assertErrorMsg
    fi
  done
}

testInteger() {
  # Valid defaults.
  for default in ${TH_INT_VALID}; do
    flags_reset
    desc="valid_int_val='${default}'"
    if DEFINE_integer intVal "${default}" 'valid integer' i
    then
      got="${FLAGS_intVal:-}" want="${default}"
      assertEquals "${desc}: incorrect FLAGS_intVal value" "${want}" "${got}"
    else
      assertEquals "${desc}: DEFINE_integer() failed unexpectedly." "${FLAGS_TRUE}" $?
    fi
  done

  # Invalid defaults.
  for default in ${TH_INT_INVALID}; do
    flags_reset
    desc="invalid_int_val='${default}'"
    if DEFINE_integer intVal "${default}" 'invalid integer' i >"${stdoutF}" 2>"${stderrF}"
    then
      fail "${desc}: expected DEFINE_integer() to fail"
    else
      assertEquals "${desc}: DEFINE_integer() expected error." "${FLAGS_ERROR}" $?
      assertErrorMsg
    fi
  done
}

testString() {
  # Valid defaults.
  for default in ${TH_BOOL_VALID} ${TH_FLOAT_VALID} ${TH_INT_VALID} 'also valid' ''
  do
    flags_reset
    desc="valid_string_val='${default}'"
    if DEFINE_string strVal "${default}" "string: ${default}" s
    then
      got="${FLAGS_strVal:-}" want="${default}"
      assertEquals "${desc}: incorrect FLAGS_strVal value" "${want}" "${got}"
    else
      assertEquals "${desc}: DEFINE_string() failed unexpectedly." "${FLAGS_TRUE}" $?
    fi
  done

  # There are no known invalid defaults.
}

testShortNameLength() {
  # Make sure short names are no longer than a single character.
  :
}

testFlagNameIsReserved() {
  if DEFINE_string TRUE '' 'true is a reserved flag name' t >"${stdoutF}" 2>"${stderrF}"
  then
    fail "expected DEFINE with reserved flag name to fail"
  else
    assertEquals "expected error from DEFINE with reserved flag" "${FLAGS_ERROR}" $?
    assertErrorMsg 'flag name (TRUE) is reserved'
  fi
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
