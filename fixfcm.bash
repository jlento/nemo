#!/usr/bin/env bash

# A tool to modify XML files used by FCM

# This is just a regexp search and replace, not a proper XML
# parser. Use at own risk.

fixfcm() {
    local name value prog=""
    for arg in "$@"; do
        name="${arg%%=*}"
	value=$(printf %q "${arg#*=}")
	value="${value//\//\/}"
        prog="s/(^%${name} )(.*)/\\1 ${value}/"$'\n'"$prog"
    done
    sed -r -e "$prog"
}
