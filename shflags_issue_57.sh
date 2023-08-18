#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# shFlags unit test for Issue #57.
# https://github.com/kward/shflags/issues/57
#
# Copyright 2023 Kate Ward. All Rights Reserved.
# Released under the Apache 2.0 license.
#
# Author: kate.ward@forestent.com (Kate Ward)
# https://github.com/kward/shflags
#
### ShellCheck (http://www.shellcheck.net/)
# Disable source following.
#   shellcheck disable=SC1090,SC1091
# $() are not fully portable (POSIX != portable).
#   shellcheck disable=SC2006

# These variables will be overridden by the test helpers.
returnF="${TMPDIR:-/tmp}/return"
stdoutF="${TMPDIR:-/tmp}/STDOUT"
stderrF="${TMPDIR:-/tmp}/STDERR"

# Load test helpers.
. ./shflags_test_helpers

# Test proper functionality with 'set -o pipefail' enabled.
testIssue57() {
  # shellcheck disable=SC3040
  set -o pipefail

  th_clearReturn
  (
    FLAGS -h >"${stdoutF}" 2>"${stderrF}"
    echo $? >"${returnF}"
  )

  assertFalse \
      'short help request should have returned a false exit code.' \
      "$(th_queryReturn)"
  ( grep 'show this help' "${stderrF}" >/dev/null )
  r3turn=$?
  assertTrue \
      'short request for help should have produced some help output.' \
      ${r3turn}
  [ ${r3turn} -eq "${FLAGS_TRUE}" ] || th_showOutput
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
