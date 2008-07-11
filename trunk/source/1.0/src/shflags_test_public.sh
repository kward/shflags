#! /bin/sh
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

# set shwordsplit for zsh
[ -n "${ZSH_VERSION:-}" ] && setopt shwordsplit

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
  assertTrue \
      'setting FLAGS_HELP did not produce expected result' \
      ${rtrn}
  [ ${rtrn} -ne ${FLAGS_TRUE} ] && echo "${rslt}" >&2

  # test that "'" chars work in help string
  DEFINE_boolean b false "help string containing a ' char" b
  rslt=`FLAGS -h 2>&1`
  echo "${rslt}" |grep -- "help string containing a ' char" >/dev/null
  rtrn=$?
  assertTrue \
      "help strings containing apostrophes don't work" \
      ${rtrn}
  [ ${rtrn} -ne ${FLAGS_TRUE} ] && echo "${rslt}" >&2

  #
  # test long --help option
  #

  flags_getoptIsStd && startSkipping

  rslt=`FLAGS --help 2>&1`
  rtrn=$?
  assertFalse \
      'long request for help should have returned non-zero exit code.' \
      ${rtrn}
  echo "${rslt}" |grep -- 'show this help' >/dev/null
  assertTrue \
      'long request for help should have produced some help output.' \
      $?
}

testStandardHelpOutput()
{
  flags_getoptIsEnh && startSkipping

  DEFINE_boolean test_bool false 'test boolean' b
  DEFINE_string test_str '' 'test string' s
  help='USAGE: standard [flags] args'

  cat >"${expectedF}" <<EOF
USAGE: standard [flags] args
flags:
  -b  test boolean
  -s  test string
  -h  show this help
EOF
  ( FLAGS_HELP=${help}; FLAGS -h >"${stdoutF}" 2>"${stderrF}" )
  diff "${expectedF}" "${stderrF}" >/dev/null
  rtrn=$?
  assertTrue 'unexpected help output' ${rtrn}
  [ ${__shunit_skip} -eq ${SHUNIT_FALSE} \
    -a ${rtrn} -ne ${FLAGS_TRUE} ] \
      && cat "${stderrF}"
}

testEnhancedHelpOutput()
{
  flags_getoptIsEnh || startSkipping

  DEFINE_boolean test_bool false 'test boolean' b
  DEFINE_string test_str '' 'test string' s
  help='USAGE: standard [flags] args'

  cat >"${expectedF}" <<EOF
USAGE: enhanced [flags] args
flags:
  -b,--[no]test_bool:  test boolean
  -s,--test_str:  test string
  -h,--[no]help:  show this help
EOF
  ( FLAGS_HELP=${help}; FLAGS -h >"${stdoutF}" 2>"${stderrF}" )
  diff "${expectedF}" "${stderrF}" >/dev/null
  rtrn=$?
  assertTrue 'short flag help; unexpected help output' ${rtrn}
  [ ${__shunit_skip} -eq ${SHUNIT_FALSE} \
    -a ${rtrn} -ne ${FLAGS_TRUE} ] \
      && cat "${stderrF}"

  # long option testing
  flags_getoptIsStd && startSkipping

  cat >"${expectedF}" <<EOF
USAGE: enhanced [flags] args
flags:
  -b,--[no]test_bool:  test boolean
  -s,--test_str:  test string
  -h,--[no]help:  show this help
EOF
  ( FLAGS_HELP=${help}; FLAGS --help >"${stdoutF}" 2>"${stderrF}" )
  diff "${expectedF}" "${stderrF}" >/dev/null
  rtrn=$?
  assertTrue 'long flag help; unexpected help output' ${rtrn}
  [ ${__shunit_skip} -eq ${SHUNIT_FALSE} \
    -a ${rtrn} -ne ${FLAGS_TRUE} ] \
      && cat "${stderrF}"
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
  expectedF="${tmpDir}/expected"
}

setUp()
{
  flags_reset
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
