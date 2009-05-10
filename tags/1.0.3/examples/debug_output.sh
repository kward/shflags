#!/bin/sh
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
#
# Author: kate.ward@forestent.com (Kate Ward)
#
# This script does the very simple job of echoing some text. If a '-d' (or
# '--debug') flag is given, additinal "debug" output is enabled.
#
# This script demonstrates the use of a boolean flag to enable custom
# functionality in a script.
#
# Try running these:
# $ ./debug_output.sh speak
# $ ./debug_output.sh sing
# $ ./debug_output.sh --debug sing

# source shflags
. ../src/shflags

# define flags
DEFINE_boolean 'debug' false 'enable debug mode' 'd'
FLAGS_HELP=`cat <<EOF
commands:
  speak:  say something
  sing:   sing something
EOF`


debug()
{
  [ ${FLAGS_debug} -eq ${FLAGS_TRUE} ] || return
  echo "DEBUG: $@" >&2
}

die() {
  [ $# -gt 0 ] && echo "error: $@" >&2
  flags_help
  exit 1
}


# parse the command-line
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

command=$1
case ${command} in
  '') die ;;

  speak)
    debug "I'm getting ready to say something..."
    echo 'The answer to the question "What is the meaning of life?" is "42".'
    ;;

  sing)
    debug "I'm getting ready to sing something..."
    echo 'I love to sing! La diddy da dum!'
    ;;

  *) die "unrecognized command (${command})" ;;
esac
