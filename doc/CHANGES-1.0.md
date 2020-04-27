# Changes in shFlags

## Changes with 1.0.3

MAJOR CHANGE! `FLAGS_ARGC` is now obsolete, and is replaced by `FLAGS_ARGV`. See
below for more info.

Fixed issue# 7 where long flags defined with '=' (e.g. `--abc=123`) made it
impossible for the user to know how many non-flag command-line arguments were
available because the value returned by `FLAGS_ARGC` was wrong. The `FLAGS_ARGC`
value is now obsolete, but will be maintained for backwards compatibility. The
new method of getting the non-flag arguments is by executing `eval set --
"${FLAGS_ARGV}"` after the `FLAGS` call. The arguments will then be available
using the standard shell $#, $@, $*, $1, etc. variables.

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

FLAGS_PARENT no longer transforms into a constant so that it can be defined at
run time in scripts.

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
