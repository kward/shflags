# shFlags 1.3.0 Release Notes

https://github.com/kward/shflags

## Preface

This document covers any known issues and workarounds for the stated release of
shFlags.

## Release info

This is the first release in the new testing series. The primary change from
1.2.3 was reworking things so that 'set -e' is supported.

Please see the `CHANGES-1.3.md` file for a complete list of changes.

### Notable changes

The obsolete `FLAGS_ARGC` variable was removed.

### Notable bug fixes

Some rewrites to ensure shell 'set -e' (as well as 'set -u' and
'set -o pipefail') are supported as expected.

## General info

### The unit tests

shFlags is designed to work on as many environments as possible, but not all
environments are created equal. As such, not all of the unit tests will succeed
on every platform. The unit tests are therefore designed to fail, indicating to
the tester that the supported functionality is not present, but an additional
test is present to verify that shFlags properly caught the limitation and
presented the user with an appropriate error message.

shFlags tries to support both the standard and enhanced versions of `getopt`. As
each responds differently, and not everything is supported on the standard
version, some unit tests will be skipped (i.e. ASSERTS will not be thrown) when
the standard version of `getopt` is detected. The reason being that there is no
point testing for functionality that is positively known not to exist. A tally
of skipped tests will be kept for later reference.

### Standard vs Enhanced getopt

Here is a matrix of the supported features of the various `getopt` variants.

Feature                                 | std | enh
--------------------------------------- | --- | ---
short option names                      | Y   | Y
long option names                       | N   | Y
spaces in string options                | N   | Y
intermixing of flag and non-flag values | N   | Y

## Known Issues

The `getopt` version provided by default with all versions of Mac OS X (up to
and including 10.13.0) and Solaris (up to and including Solaris 10 and
OpenSolaris) is the standard version.

## Workarounds

The Zsh shell requires the `shwordsplit` option to be set and the special
`FLAGS_PARENT` variable must be defined. See `src/shflags_test_helpers` to see
how the unit tests do this.
