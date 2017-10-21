#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# shFlags unit test for https://github.com/kward/shflags/issues/28.
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
      'short help request should have returned a false exit code.' \
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

mock_flags_columns() {
  echo 80
}

_doDefines() {
  DEFINE_boolean 'force' false '' f
}

testStandardHelpOutput() {
  flags_getoptIsStd || startSkipping

  _doDefines
  help='USAGE: standard [flags] args'

  cat >"${expectedF}" <<EOF
${help}
flags:
  -f  (default: false)
  -h  show this help (default: false)
EOF
  (
    _flags_columns() { mock_flags_columns; }
    FLAGS_HELP=${help};
    FLAGS -h >"${stdoutF}" 2>"${stderrF}"
  )
  diff "${expectedF}" "${stderrF}" >/dev/null
  r3turn=$?
  assertTrue 'unexpected help output' ${r3turn}
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"
}

testEnhancedHelpOutput() {
  flags_getoptIsEnh || startSkipping

  _doDefines
  help='USAGE: enhanced [flags] args'

  cat >"${expectedF}" <<EOF
${help}
flags:
  -f,--[no]force:  (default: false)
  -h,--help:  show this help (default: false)
EOF
  (
    _flags_columns() { mock_flags_columns; }
    # shellcheck disable=SC2034
    FLAGS_HELP=${help};
    FLAGS -h >"${stdoutF}" 2>"${stderrF}"
  )
  diff "${expectedF}" "${stderrF}" >/dev/null
  differed=$?
  assertTrue 'unexpected help output' ${differed}
  th_showOutput ${differed} "${stdoutF}" "${stderrF}"
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
