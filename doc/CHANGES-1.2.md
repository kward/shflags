# Changes in shFlags

## Changes with 1.2.3pre

Upgraded shUnit2 to 2.1.7.

Fixed the examples to work again with the new code structure.

Removed `gen_test_report.sh` as it isn't used anymore.

Minor fix for `_flags_underscoreName()` to insure POSIX compliance.

Cleanup of pre-GitHub cruft.

Fixed bug in `_flags_columns()` where `stty size` sometimes gave unexpected
output, causing the function to not work.

Replaced `test_runner` with upstream from https://github.com/kward/shlib.

## Changes with 1.2.2

Ran all scripts through [ShellCheck](http://www.shellcheck.net/).

Replaced `shflags_test.sh` with `test_runner` from
https://github.com/kward/shlib.

Fixed issue #45. Empty help string causes `shflags_test_issue_28.sh` to fail.

Continuous integration testing setup with [Travis
CI](https://travis-ci.org/kward/shflags).

Restructured code to be more GitHub like.

## Changes with 1.2.1

Fixed issue #43. Added support for BusyBox `ash` shell.

Fixed issues #26, #27. Re-factored `_flags_itemInList()` to use built-ins.

Fixed issue #31. Documented newline support in FLAGS_HELP.

Fixed issue #28. DEFINE_boolean misbehaves when help-string is empty.

Fixed issue #25. Fix some typos.

## Changes with 1.2.0

Changed from the LGPL v2.1 license to the Apache v2.0 license so that others can
include the library or make changes without needing to release the modified
source code as well.

Moved documentation to Markdown.

Migrated the code to GitHub as http://code.google.com/ is turning down.

Fixed issue #10. Usage of `expr` under FreeBSD 7.2 (FreeNAS 0.7.1) and FreeBSD
8.0 that was causing many unit tests to fail.

Fixed issue where booleans were sometimes mis-configured to require additional
values like other flags.

Changed `_flags_fatal()` to exit with `FLAGS_ERROR` immediately.

Fixed issue #11. When help is requested, the help flag is no longer prefixed
with '[no]'.

Upgraded shUnit2 to 2.1.6.

Fixed issue #12. Requesting help shouldn't be considered an error.

Added the ability to override the use of the OS default `getopt` command by
defining the `FLAGS_GETOPT_CMD` variable.

Updated `gen_test_results.sh` and versions from shUnit2 source.

Fixed issues# 13, 14. Added support for dashes '-' in long flag names. The
defined flag will still be declared with underscores '\_' due to shell
limitations, so only one of a dashed flag name or an underscored flag name are
allowed, not both. (Backslash on \_ to prevent Markdown formatting.)

Issue #20. Updated LGPL v2.1 license from
http://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt.

Issue #15. Use `gexpr` instead of `expr` on BSD variants.

Minor tweaks to make run on FreeBSD 9.1.

Fixed issue in `shflags_test_public.sh` where screens >80 columns were causing a
test to fail.

Issue #22. Fixed broken testGetFlagInfo() test.

Created alternate `validFloat()` and `validInt()` functions that use shell
built-ins where possible to increase performance and reduce the usage of the
`expr` command.

Added separate built-in and `expr` functions for doing math.

## Changes with 1.0.3

MAJOR CHANGE! `FLAGS_ARGC` is now obsolete, and is replaced by `FLAGS_ARGV`. See
below for more info.

Fixed issue# 7 where long flags defined with '=' (e.g. `--abc=123`) made it
impossible for the user to know how many non-flag command-line arguments were
available because the value returned by `FLAGS_ARGC` was wrong. The `FLAGS_ARGC`
value is now obsolete, but will be maintained for backwards compatibility. The
new method of getting the non-flag arguments is by executing `eval set --
"${FLAGS_ARGV}"` after the `FLAGS` call. The arguments will then be available
using the standard shell $#, $@, $\*, $1, etc. variables. (Backslash on \* to
prevent Markdown formatting.)

Due to above fix for issue# 7, there is now proper support for mixing flags with
non-flag arguments on the command-line. Previously, all non-flag arguments had
to be at the end of the command-line.

Renamed `_flags_standardGetopt()` and `_flags_enhancedGetopt()` functions to
`_flags_getoptStandard()` and `_flags_getoptEnhanced()`.

Took out the setting and restoration of the '-u' shell flag to treat unset
variables as an error. No point in having it in this library as it is verified
in the unit tests, and provides basically no benefit.

Fixed bug under Solaris where the generated help was adding extra 'x'
characters.

Added checks for reserved flag variables (e.g. `FLAGS_TRUE`).

Fixed some unset variable bugs.

Now report the actual `getopt` error if there is one.

All tests now properly enable skipping based on whether a standard or enhanced
`getopt` is found.

Added the OS version to OS release for Solaris.

Fixed `flags_reset()` so it unsets the default value environment vars.

## Changes with 1.0.2

${FLAGS_PARENT} no longer transforms into a constant so that it can be defined
at run time in scripts.

Added warning about short flags being unsupported when there are problems
parsing the options with `getopt`.

Add default values to end of description strings.

Fixed bug that returned an error instead of success when recalling the default
values for empty strings.

Added warning when a duplicate flag definition is attempted.

Improved `assert[Warn|Error]Msg()` test helper grepping.

Replaced shell_versions.sh with a new versions library and created
`gen_test_results.sh` to make releases easier.

Copied the coding standards from shUnit2, but haven't fully implemented them in
shFlags yet.

Issue# 1: When a user defines their own `--help` flag, no more warning is thrown
when `FLAGS()` is called stating that the help flag already defined.

Issue# 2: Passing the `--nohelp` option no longer gives help output.

Issue# 3: Added support for screen width detection.

## Changes with 1.0.1

Fixed bug where the help output added '[no]' to all flag names

Added additional example files that are referenced by the documentation.

Improved `zsh` version and option checking.

Upgraded shUnit2 to 2.1.4

Added unit testing for the help output.

When including a library (e.g. shflags) in a script, zsh 3.0.8 doesn't actually
execute the code in-line, but later. As such, variables that are defined in the
library cannot be used until functions are called from the main code. This
required the 'help' flag definition to be moved inside the FLAGS command.

## Changes with 1.0.0

This is the first official release, so everything is new.
