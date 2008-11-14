#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# shFlags unit test for the public functions

# load test helpers
. ./shflags_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testHelp()
{
  #
  # test short -h option
  #

  rslt=`FLAGS -h 2>&1`
  rtrn=$?
  assertFalse \
      'short request for help should have returned non-zero exit code.' \
      ${rtrn}
  echo "${rslt}" |grep -- 'show this help' >/dev/null
  rtrn=$?
  assertTrue \
      'short request for help should have produced some help output.' \
      ${rtrn}
  [ ${rtrn} -ne ${FLAGS_TRUE} ] && echo "${rslt}" >&2

  # test proper output when FLAGS_HELP set
  rslt=`FLAGS_HELP='this is a test'; FLAGS -h 2>&1`
  echo "${rslt}" |grep -- 'this is a test' >/dev/null
  rtrn=$?
  assertTrue 'setting FLAGS_HELP did not produce expected result' ${rtrn}
  [ ${rtrn} -ne ${FLAGS_TRUE} ] && echo "${rslt}" >&2

  # test that "'" chars work in help string
  DEFINE_boolean b false "help string containing a ' char" b
  rslt=`FLAGS -h 2>&1`
  echo "${rslt}" |grep -- "help string containing a ' char" >/dev/null
  rtrn=$?
  assertTrue "help strings containing apostrophes don't work" ${rtrn}
  [ ${rtrn} -ne ${FLAGS_TRUE} ] && echo "${rslt}" >&2

  #
  # test long --help option
  #

  flags_getoptIsEnh || startSkipping

  rslt=`FLAGS --help 2>&1`
  assertFalse 'long help request should have returned non-zero exit code' $?
  echo "${rslt}" |grep -- 'show this help' >/dev/null
  assertTrue 'long help request should have produced some help output.' $?
}

testStandardHelpOutput()
{
  flags_getoptIsStd || startSkipping

  DEFINE_boolean test_bool false 'test boolean' b
  DEFINE_integer test_int 0 'test integer' i
  DEFINE_string test_str '' 'test string' s
  DEFINE_string long_desc 'blah' \
      'testing of a long description to force wrap of default value' l
  help='USAGE: standard [flags] args'

  cat >"${expectedF}" <<EOF
USAGE: standard [flags] args
flags:
  -b  test boolean (default: false)
  -i  test integer (default: 0)
  -s  test string (default: '')
  -l  testing of a long description to force wrap of default value
      (default: 'blah')
  -h  show this help (default: false)
EOF
  ( FLAGS_HELP=${help}; FLAGS -h >"${stdoutF}" 2>"${stderrF}" )
  diff "${expectedF}" "${stderrF}" >/dev/null
  rtrn=$?
  assertTrue 'unexpected help output' ${rtrn}
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
}

testEnhancedHelpOutput()
{
  flags_getoptIsEnh || startSkipping

  DEFINE_boolean test_bool false 'test boolean' b
  DEFINE_integer test_int 0 'test integer' i
  DEFINE_string test_str '' 'test string' s
  DEFINE_string long_desc 'blah' \
      'testing of a long description to force wrap of default value' l
  help='USAGE: enhanced [flags] args'

  cat >"${expectedF}" <<EOF
USAGE: enhanced [flags] args
flags:
  -b,--[no]test_bool:  test boolean (default: false)
  -i,--test_int:  test integer (default: 0)
  -s,--test_str:  test string (default: '')
  -l,--long_desc:  testing of a long description to force wrap of default value
                   (default: 'blah')
  -h,--[no]help:  show this help (default: false)
EOF
  ( FLAGS_HELP=${help}; FLAGS -h >"${stdoutF}" 2>"${stderrF}" )
  diff "${expectedF}" "${stderrF}" >/dev/null
  assertTrue 'unexpected help output' $?
  [ ${__shunit_skip} -eq ${SHUNIT_FALSE} -a ${rtrn} -ne ${FLAGS_TRUE} ] \
      && cat "${stderrF}"
}

testNoHelp()
{
  flags_getoptIsEnh || startSkipping

  ( FLAGS --nohelp >"${stdoutF}" 2>"${stderrF}" )
  rtrn=$?
  assertTrue "FLAGS returned a non-zero result (${rtrn})" ${rtrn}
  assertFalse 'expected no output to STDOUT' "[ -s '${stdoutF}' ]"
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
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
