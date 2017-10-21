#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# shFlags unit test for the public functions.
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

# These variables will be overridden by the test helpers.
expectedF="${TMPDIR:-/tmp}/expected"
returnF="${TMPDIR:-/tmp}/return"
stdoutF="${TMPDIR:-/tmp}/STDOUT"
stderrF="${TMPDIR:-/tmp}/STDERR"

# Load test helpers.
. ./shflags_test_helpers

testHelp() {
  _testHelp '-h'
  flags_getoptIsEnh || return
  _testHelp '--help'
}

_testHelp() {
  flag=$1

  # Test default help output.
  th_clearReturn
  (
    FLAGS "${flag}" >"${stdoutF}" 2>"${stderrF}"
    echo $? >"${returnF}"
  )
  assertFalse \
      'a call for help should return a non-zero exit code.' \
      "$(th_queryReturn)"
  grep 'show this help' "${stderrF}" >/dev/null
  grepped=$?
  assertTrue \
      'short request for help should have produced some help output.' \
      ${grepped}
  [ ${grepped} -ne "${FLAGS_TRUE}" ] && th_showOutput

  # Test proper output when FLAGS_HELP set.
  (
    FLAGS_HELP='this is a test'
    FLAGS "${flag}" >"${stdoutF}" 2>"${stderrF}"
  )
  grep 'this is a test' "${stderrF}" >/dev/null
  grepped=$?
  assertTrue 'setting FLAGS_HELP did not produce expected result' ${grepped}
  [ ${grepped} -ne "${FLAGS_TRUE}" ] && th_showOutput

  # test that "'" chars work in help string
  (
    DEFINE_boolean b false "help string containing a ' char" b
    FLAGS "${flag}" >"${stdoutF}" 2>"${stderrF}"
  )
  grep "help string containing a ' char" "${stderrF}" >/dev/null
  grepped=$?
  assertTrue "help strings containing apostrophes don't work" ${grepped}
  [ ${grepped} -ne "${FLAGS_TRUE}" ] && th_showOutput
}

mock_flags_columns()
{
  echo 80
}

testStandardHelpOutput() {
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
  (
    _flags_columns() { mock_flags_columns; }
    FLAGS_HELP=${help};
    FLAGS -h >"${stdoutF}" 2>"${stderrF}"
    echo $? >"${returnF}"
  )
  assertFalse \
      'a call for help should return a non-zero exit code.' \
      "$(th_queryReturn)"

  diff "${expectedF}" "${stderrF}" >/dev/null
  r3turn=$?
  assertTrue 'unexpected help output' ${r3turn}
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"
}

testEnhancedHelpOutput() {
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
  -h,--help:  show this help (default: false)
EOF
  (
    _flags_columns() { mock_flags_columns; }
    # shellcheck disable=SC2034
    FLAGS_HELP=${help};
    FLAGS -h >"${stdoutF}" 2>"${stderrF}"
    echo $? >"${returnF}"
  )
  assertFalse \
      'a call for help should return a non-zero exit code.' \
      "$(th_queryReturn)"

  diff "${expectedF}" "${stderrF}" >/dev/null
  differed=$?
  assertTrue 'unexpected help output' ${differed}
  th_showOutput ${differed} "${stdoutF}" "${stderrF}"
}

testNoHelp() {
  flags_getoptIsEnh || startSkipping

  ( FLAGS --nohelp >"${stdoutF}" 2>"${stderrF}" )
  r3turn=$?
  assertTrue "FLAGS returned a non-zero result (${r3turn})" ${r3turn}
  assertFalse 'expected no output to STDOUT' "[ -s '${stdoutF}' ]"
  assertFalse 'expected no output to STDERR' "[ -s '${stderrF}' ]"
}

testLoggingLevel() {
  # Check that the default logging level is set properly.
  got=$(flags_loggingLevel) want=${__FLAGS_LEVEL_DEFAULT}
  assertTrue "Unexpected default logging level = ${got}, want ${want}" "[ ${got} -eq ${want} ]"

  # Override the logging level, and check again.
  flags_setLoggingLevel "${FLAGS_LEVEL_FATAL}"
  flags_setLoggingLevel "${FLAGS_LEVEL_INFO}"
  got=$(flags_loggingLevel) want=${FLAGS_LEVEL_INFO}
  assertTrue "Unexpected configured logging level = ${got}, want ${want}" "[ ${got} -eq ${want} ]"
}

oneTimeSetUp() {
  th_oneTimeSetUp

  if flags_getoptIsStd; then
    th_warn 'Standard version of getopt found. Enhanced tests will be skipped.'
    return
  fi
  th_warn 'Enhanced version of getopt found. Standard tests will be skipped.'
}

setUp() {
  flags_reset
}

# Load and run shUnit2.
# shellcheck disable=SC2034
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. "${TH_SHUNIT}"
