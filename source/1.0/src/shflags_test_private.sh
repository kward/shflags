#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# shFlags unit test for the internal functions

# load test helpers
. ./shflags_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testColumns()
{
  cols=`_flags_columns`
  value=`expr "${cols}" : '\([0-9]*\)'`
  assertNotNull "unexpected screen width (${cols})" "${value}"
}

testExpr()
{
  :
}

testGenOptStr()
{
  _testGenOptStr '' ''

  DEFINE_boolean bool false 'boolean value' b
  _testGenOptStr 'b' 'bool'

  DEFINE_float float 0.0 'float value' f
  _testGenOptStr 'bf:' 'bool,float:'

  DEFINE_integer int 0 'integer value' i
  _testGenOptStr 'bf:i:' 'bool,float:,int:'

  DEFINE_string str 0 'string value' s
  _testGenOptStr 'bf:i:s:' 'bool,float:,int:,str:'

  DEFINE_boolean help false 'show help' h
  _testGenOptStr 'bf:i:s:h' 'bool,float:,int:,str:,help'
}

_testGenOptStr()
{
  short=$1
  long=$2

  result=`_flags_genOptStr ${__FLAGS_OPTSTR_SHORT}`
  assertTrue 'short option string generation failed' $?
  assertEquals "${short}" "${result}"

  result=`_flags_genOptStr ${__FLAGS_OPTSTR_LONG}`
  assertTrue 'long option string generation failed' $?
  assertEquals "${long}" "${result}"
}

testGetFlagInfo()
{
  __flags_blah_foobar='1234'

  rslt=`_flags_getFlagInfo 'blah' 'foobar'`
  assertTrue 'request for valid flag info failed' $?
  assertEquals 'invalid flag info returned' "${__flags_blah_foobar}" "${rslt}"

  rslt=`_flags_getFlagInfo 'blah' 'hubbabubba' >"${stdoutF}" 2>"${stderrF}"`
  assertEquals 'invalid flag did not result in an error' ${FLAGS_ERROR} $?
  assertErrorMsg 'missing flag info variable'
}

testItemInList()
{
  list='this is a test'

  _flags_itemInList 'is' ${list}
  assertTrue 'unable to find leading string (this)' $?

  _flags_itemInList 'is' ${list}
  assertTrue 'unable to find string (is)' $?

  _flags_itemInList 'is' ${list}
  assertTrue 'unable to find trailing string (test)' $?

  _flags_itemInList 'abc' ${list}
  assertFalse 'found nonexistant string (abc)' $?

  _flags_itemInList '' ${list}
  assertFalse 'empty strings should not match' $?

  _flags_itemInList 'blah' ''
  assertFalse 'empty lists should not match' $?
}

testValidBool()
{
  # valid values
  for value in ${TH_BOOL_VALID}; do
    _flags_validBool "${value}"
    assertTrue "valid value (${value}) did not validate" $?
  done

  # invalid values
  for value in ${TH_BOOL_INVALID}; do
    _flags_validBool "${value}"
    assertFalse "invalid value (${value}) validated" $?
  done
}

_testValidFloat()
{
  fx=$1

  # valid values
  for value in ${TH_INT_VALID} ${TH_FLOAT_VALID}; do
    ${fx} "${value}"
    assertTrue "valid value (${value}) did not validate" $?
  done

  # invalid values
  for value in ${TH_FLOAT_INVALID}; do
    ${fx} "${value}"
    assertFalse "invalid value (${value}) validated" $?
  done
}

testValidFloatBuiltin()
{
  # Are we running a shell that can handle a built-in version? The Solaris
  # Bourne shell for one does not support what we need.
  if [ "${__FLAGS_FX_VALID_FLOAT}" != '_flags_validFloatBuiltin' ]; then
    echo 'SKIPPED: this shell does not support the necessary builtins'
    return
  fi
  _testValidFloat _flags_validFloatBuiltin
}

testValidFloatExpr()
{
  _testValidFloat _flags_validFloatExpr
}

_testValidInt()
{
  fx=$1

  # valid values
  for value in ${TH_INT_VALID}; do
    ${fx} "${value}"
    assertTrue "valid value (${value}) did not validate" $?
  done

  # invalid values
  for value in ${TH_INT_INVALID}; do
    ${fx} "${value}"
    assertFalse "invalid value (${value}) should not validate" $?
  done
}

testValidIntBuiltin()
{
  # Are we running a shell that can handle a built-in version? The Solaris
  # Bourne shell for one does not support what we need.
  if [ "${__FLAGS_FX_VALID_INT}" != '_flags_validIntBuiltin' ]; then
    echo 'SKIPPED: this shell does not support the necessary builtins'
    return
  fi
  _testValidInt _flags_validIntBuiltin
}

testValidIntExpr()
{
  _testValidInt _flags_validIntExpr
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  th_oneTimeSetUp
}

setUp()
{
  flags_reset
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
