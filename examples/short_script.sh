#!/bin/bash
set -euo pipefail
# this is short script example

# shellcheck disable=SC1091
. "$(dirname "${BASH_SOURCE[0]}")/_functions"

while [[ $# -gt 0 ]]; do
  case $1 in
    # optional (You can omit the optional argument. Omitting the argument will set the default value.)
    --debug) _DEBUG=$2; shift 2; ;;
    *) shift ;;
  esac
done

# Variable initialization and show
common::print "Arguments:"
common::print "--debug=${_DEBUG:="false"}"

# Enable debug mode
common::debug_mode

common::print "Main started."
curl https://example.com
