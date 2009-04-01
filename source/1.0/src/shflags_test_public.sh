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
      'testing of a long description to force wrap of default value' D
  DEFINE_string long_default \
      'this_is_a_long_default_value_to_force_alternate_indentation' \
      'testing of long default value' F
  help='USAGE: standard [flags] args'

  cat >"${expectedF}" <<EOF
${help}
flags:
  -b  test boolean (default: false)
  -i  test integer (default: 0)
  -s  test string (default: '')
  -D  testing of a long description to force wrap of default value
      (default: 'blah')
  -F  testing of long default value
      (default: 'this_is_a_long_default_value_to_force_alternate_indentation')
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
      'testing of a long description to force wrap of default value' D
  DEFINE_string long_default \
      'this_is_a_long_default_value_to_force_alternate_indentation' \
      'testing of long default value' F
  help='USAGE: enhanced [flags] args'

  cat >"${expectedF}" <<EOF
${help}
flags:
  -b,--[no]test_bool:  test boolean (default: false)
  -i,--test_int:  test integer (default: 0)
  -s,--test_str:  test string (default: '')
  -D,--long_desc:  testing of a long description to force wrap of default value
                   (default: 'blah')
  -F,--long_default:  testing of long default value
    (default: 'this_is_a_long_default_value_to_force_alternate_indentation')
  -h,--[no]help:  show this help (default: false)
EOF
  ( FLAGS_HELP=${help}; FLAGS -h >"${stdoutF}" 2>"${stderrF}" )
  diff "${expectedF}" "${stderrF}" >/dev/null
  rtrn=$?
  assertTrue 'unexpected help output' ${rtrn}
  th_showOutput ${rtrn} "${stdoutF}" "${stderrF}"
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

  if flags_getoptIsStd; then
    th_warn 'Standard version of getopt found. Enhanced tests will be skipped.'
  else
    th_warn 'Enhanced version of getopt found. Standard tests will be skipped.'
  fi
}

setUp()
{
  flags_reset
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
