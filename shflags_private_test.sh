#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# shFlags unit tests for the internal functions.
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
# expr may be antiquated, but it is the only solution in some cases.
#   shellcheck disable=SC2003
# $() are not fully portable (POSIX != portable).
#   shellcheck disable=SC2006

# These variables will be overridden by the test helpers.
stdoutF="${TMPDIR:-/tmp}/STDOUT"
stderrF="${TMPDIR:-/tmp}/STDERR"

# Load test helpers.
. ./shflags_test_helpers

testColumns() {
  cols=`_flags_columns`
  value=`expr "${cols}" : '\([0-9]*\)'`
  assertNotNull "unexpected screen width (${cols})" "${value}"
}

testGetoptVers() {
  # shellcheck disable=SC2162
  while read desc mock want; do
    assertEquals "${desc}" "$(_flags_getopt_vers "${mock}")" "${want}"
  done <<EOF
standard mock_getopt_std ${__FLAGS_GETOPT_VERS_STD}
enhanced mock_getopt_enh ${__FLAGS_GETOPT_VERS_ENH}
EOF
}

### The mock_getopt_* commands behave like "getopt -lfoo '' --foo" was called.
# macOS 10.13.0.
mock_getopt_std() { echo ' -- --foo'; return 0; }
# Ubuntu 16.04.3
mock_getopt_enh() { echo ' --foo --'; return 0; }

testGenOptStr() {
  _testGenOptStr '' ''

  # shellcheck disable=SC2034
  DEFINE_boolean bool false 'boolean value' b
  _testGenOptStr 'b' 'bool'

  # shellcheck disable=SC2034
  DEFINE_float float 0.0 'float value' f
  _testGenOptStr 'bf:' 'bool,float:'

  # shellcheck disable=SC2034
  DEFINE_integer int 0 'integer value' i
  _testGenOptStr 'bf:i:' 'bool,float:,int:'

  # shellcheck disable=SC2034
  DEFINE_string str 0 'string value' s
  _testGenOptStr 'bf:i:s:' 'bool,float:,int:,str:'

  # shellcheck disable=SC2034
  DEFINE_boolean help false 'show help' h
  _testGenOptStr 'bf:i:s:h' 'bool,float:,int:,str:,help'
}

_testGenOptStr() {
  short=$1
  long=$2

  result=`_flags_genOptStr "${__FLAGS_OPTSTR_SHORT}"`
  assertTrue 'short option string generation failed' $?
  assertEquals "${short}" "${result}"

  result=`_flags_genOptStr "${__FLAGS_OPTSTR_LONG}"`
  assertTrue 'long option string generation failed' $?
  assertEquals "${long}" "${result}"
}

testGetFlagInfo() {
  __flags_blah_foobar='1234'

  desc='valid_flag'
  if rslt="`_flags_getFlagInfo 'blah' 'foobar'`"; then
    assertEquals "${desc}: invalid flag result" "${__flags_blah_foobar}" "${rslt}"
  else
    fail "${desc}: request for valid flag info failed"
  fi

  desc='invalid_flag'
  if rslt="`_flags_getFlagInfo 'blah' 'hubbabubba' >"${stdoutF}" 2>"${stderrF}"`"; then
    fail "${desc}: expected invalid flag request to fail"
    th_showOutput
  else
    assertEquals "${desc}: expected an error" "${FLAGS_ERROR}" $?
    assertErrorMsg "missing flag info variable"
  fi
}

testItemInList() {
  list='this is a test'
  # shellcheck disable=SC2162
  while read desc item want; do
    if [ "${want}" -eq "${FLAGS_TRUE}" ]; then
      continue
    fi
    got=${FLAGS_TRUE}
    if ! _flags_itemInList "${item}" "${list}"; then
      got=${FLAGS_FALSE}
    fi
    assertEquals "${desc}: itemInList(${item})" "${want}" "${got}"
  done <<EOF
lead_item       this ${FLAGS_TRUE}
middle_item     is   ${FLAGS_TRUE}
last_item       test ${FLAGS_TRUE}
missing_item    asdf ${FLAGS_FALSE}
test_partial_te te   ${FLAGS_FALSE}
test_partial_es es   ${FLAGS_FALSE}
test_partial_st st   ${FLAGS_FALSE}
empty_item      ''   ${FLAGS_FALSE}
EOF

  if _flags_itemInList 'item' ''; then
    fail 'empty lists should not match'
  fi
}

testUnderscoreName() {
  # shellcheck disable=SC2162
  while read desc name want; do
    got=`_flags_underscoreName "${name}"`
    assertEquals "${desc}: underscoreName(${name})" "${got}" "${want}"
  done <<EOF
with_dashes        name-with-dashes      name_with_dashes
with_underscores   name_with_underscores name_with_underscores
just_alpha_numeric abc123                abc123
empty              ""                    ""
EOF
}

testBool() {
  # Valid values.
  for value in ${TH_BOOL_VALID}; do
    got=${FLAGS_TRUE}
    if ! _flags_validBool "${value}"; then
      got=${FLAGS_FALSE}
    fi
    assertTrue "valid value (${value}) did not validate" "${got}"
  done

  # Invalid values.
  for value in ${TH_BOOL_INVALID}; do
    got=${FLAGS_FALSE}
    if _flags_validBool "${value}"; then
      got=${FLAGS_TRUE}
    fi
    assertFalse "invalid value (${value}) validated" "${got}"
  done
}

_testValidFloat() {
  # Valid values.
  for value in ${TH_INT_VALID} ${TH_FLOAT_VALID}; do
    got=${FLAGS_TRUE}
    if ! _flags_validFloat "${value}"; then
      got=${FLAGS_FALSE}
    fi
    assertTrue "valid value (${value}) did not validate" "${got}"
  done

  # Invalid values.
  for value in ${TH_FLOAT_INVALID}; do
    got=${FLAGS_FALSE}
    if _flags_validFloat "${value}"; then
      got=${FLAGS_TRUE}
    fi
    assertFalse "invalid value (${value}) validated" "${got}"
  done
}

testValidFloatBuiltin() {
  if ! _flags_useBuiltin; then
    startSkipping
  fi
  _testValidFloat
}

testValidFloatExpr() {
  (
    _flags_useBuiltin() { return "${FLAGS_FALSE}"; }
    _testValidFloat
  )
}

_testValidInt() {
  # Valid values.
  for value in ${TH_INT_VALID}; do
    got=${FLAGS_TRUE}
    if ! _flags_validInt "${value}"; then
      got=${FLAGS_FALSE}
    fi
    assertTrue "valid value (${value}) did not validate" "${got}"
  done

  # Invalid values.
  for value in ${TH_INT_INVALID}; do
    got=${FLAGS_FALSE}
    if _flags_validInt "${value}"; then
      got=${FLAGS_TRUE}
    fi
    assertFalse "invalid value (${value}) should not validate" "${got}"
  done
}

testValidIntBuiltin() {
  if ! _flags_useBuiltin; then
    startSkipping
  fi
  _testValidInt
}

testValidIntExpr() {
  (
    _flags_useBuiltin() { return "${FLAGS_FALSE}"; }
    _testValidInt
  )
}

_testMath() {
  if result=`_flags_math 1`; then
    assertEquals '1' 1 "${result}"
  else
    fail '1 failed'
  fi

  if result=`_flags_math '1 + 2'`; then
    assertEquals '1+2' 3 "${result}"
  else
    fail '1+2 failed'
  fi

  if result=`_flags_math '1 + 2 + 3'`; then
    assertEquals '1+2+3' 6 "${result}"
  else
    fail '1+2+3 failed'
  fi

  got=${FLAGS_TRUE}
  if ! _flags_math >/dev/null 2>&1; then
    got=${FLAGS_FALSE}
  fi
  assertFalse 'missing math succeeded' "${got}"
}

testMathBuiltin() {
  _flags_useBuiltin || startSkipping
  _testMath
}

testMathExpr() {
  (
    _flags_useBuiltin() { return "${FLAGS_FALSE}"; }
    _testMath
  )
}

_testStrlen() {
  len=`_flags_strlen`
  assertTrue 'missing argument failed' $?
  assertEquals 'missing argument' 0 "${len}"

  len=`_flags_strlen ''`
  assertTrue 'empty argument failed' $?
  assertEquals 'empty argument' 0 "${len}"

  len=`_flags_strlen abc123`
  assertTrue 'single-word failed' $?
  assertEquals 'single-word' 6 "${len}"

  len=`_flags_strlen 'This is a test'`
  assertTrue 'multi-word failed' $?
  assertEquals 'multi-word' 14 "${len}"
}

testStrlenBuiltin() {
  _flags_useBuiltin || startSkipping
  _testStrlen
}

testStrlenExpr() {
  (
    _flags_useBuiltin() { return "${FLAGS_FALSE}"; }
    _testStrlen
  )
}

oneTimeSetUp() {
  th_oneTimeSetUp

  _flags_useBuiltin || \
    th_warn 'Shell built-ins not supported. Some tests will be skipped.'
}

tearDown() {
  flags_reset
}

# Load and run shUnit2.
# shellcheck disable=SC2034
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. "${TH_SHUNIT}"
