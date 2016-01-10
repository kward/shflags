#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# shFlags unit test for the public functions

# load test helpers
. ./shflags_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testHelp()
{
  _testHelp '-h'
  flags_getoptIsEnh || return
  _testHelp '--help'
}

_testHelp()
{
  flag=$1

  # test default help output
  th_clearReturn
  (
    FLAGS ${flag} >"${stdoutF}" 2>"${stderrF}"
    echo $? >"${returnF}"
  )
  th_queryReturn
  assertTrue \
      'short help request should have returned a true exit code.' \
      ${th_return}
  grep 'show this help' "${stderrF}" >/dev/null
  grepped=$?
  assertTrue \
      'short request for help should have produced some help output.' \
      ${grepped}
  [ ${grepped} -ne ${FLAGS_TRUE} ] && th_showOutput

  # test proper output when FLAGS_HELP set
  (
    FLAGS_HELP='this is a test'
    FLAGS ${flag} >"${stdoutF}" 2>"${stderrF}"
  )
  grep 'this is a test' "${stderrF}" >/dev/null
  grepped=$?
  assertTrue 'setting FLAGS_HELP did not produce expected result' ${grepped}
  [ ${grepped} -ne ${FLAGS_TRUE} ] && th_showOutput

  # test that "'" chars work in help string
  (
    DEFINE_boolean b false "help string containing a ' char" b
    FLAGS ${flag} >"${stdoutF}" 2>"${stderrF}"
  )
  grep "help string containing a ' char" "${stderrF}" >/dev/null
  grepped=$?
  assertTrue "help strings containing apostrophes don't work" ${grepped}
  [ ${grepped} -ne ${FLAGS_TRUE} ] && th_showOutput
}

mock_flags_columns()
{
  echo 80
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
  (
    _flags_columns() { mock_flags_columns; }
    FLAGS_HELP=${help};
    FLAGS -h >"${stdoutF}" 2>"${stderrF}"
  )
  r3turn=$?
  assertTrue 'a call for help should not return an error' ${r3turn}

  diff "${expectedF}" "${stderrF}" >/dev/null
  r3turn=$?
  assertTrue 'unexpected help output' ${r3turn}
  th_showOutput ${r3turn} "${stdoutF}" "${stderrF}"
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
  -h,--help:  show this help (default: false)
EOF
  (
    _flags_columns() { mock_flags_columns; }
    FLAGS_HELP=${help};
    FLAGS -h >"${stdoutF}" 2>"${stderrF}"
  )
  r3turn=$?
  assertTrue 'a call for help should not return an error' ${r3turn}

  diff "${expectedF}" "${stderrF}" >/dev/null
  differed=$?
  assertTrue 'unexpected help output' ${differed}
  th_showOutput ${differed} "${stdoutF}" "${stderrF}"
}

testNoHelp()
{
  flags_getoptIsEnh || startSkipping

  ( FLAGS --nohelp >"${stdoutF}" 2>"${stderrF}" )
  r3turn=$?
  assertTrue "FLAGS returned a non-zero result (${r3turn})" ${r3turn}
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
