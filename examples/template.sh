#!/bin/bash
set -euo pipefail
# description of this script

# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_functions"

# --help display function (omittable)
function help() {
  cat <<EOF
  usage: $(basename "$0") --parameter1 <string> [options]
  Required:
    --param1     <string>    Description.
  Options:
    --option1    <string>    Description (default: foo).
    --aws-args   <string>    AWS CLI arguments. (default: "")
    --debug      true|false  Enable debug output. (default: false)
    --dry-run    true|false  Enable dry-run mode. (default: true)
    --help                   Output this help.
EOF
}

# parameter handling (omittable)
while [[ $# -gt 0 ]]; do
  case $1 in
    # required (Do not omit the required argument)
    --param1) _PARAM1=$2; shift 2; ;;
    # optional (You can omit the optional argument. Omitting the argument will set the default value.)
    --option1) _OPTION1=$2; shift 2; ;;
    --aws-args) _AWS_ARGS=$2; shift 2; ;;
    --debug) _DEBUG=$2; shift 2; ;;
    --dry-run) _DRYRUN=$2; shift 2; ;;
    --help) help; exit;;
    *) shift ;;
  esac
done

# Constants declartion (ommittable)
readonly CONSTANTS_VALUE='value'

# Function declartion (ommittable)
function foo {
  echo "execute foo"
}

# Variable initialization and show
common::print "Arguments:"
common::print "--param1=${_PARAM1}" # if argument not specified for required parameter, script will stop at this line.
common::print "--option1=${_OPTION1:="foo"}" # if argument not specified for optional parameter, initialize with default value.
common::print "--aws-args=${_AWS_ARGS:=""}"
common::print "--debug=${_DEBUG:="false"}"
common::print "--dry-run=${_DRYRUN:="true"}"

common::print "Config:"
common::print "* CONSTANTS_VALUE=${CONSTANTS_VALUE}"

# Enable debug mode
common::debug_mode

# Enable dryrun mode
dryrun=""
if [[ "${_DRYRUN}" == "true" ]]; then
  dryrun="echo (dryrun) "
fi

# Main execution
common::print "Main started."
$dryrun curl https://example.com
