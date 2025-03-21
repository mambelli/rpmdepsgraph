#!/bin/bash

# SPDX-FileCopyrightText: 2025 Marco Mambelli
# SPDX-License-Identifier: Apache-2.0

help_msg() {
    cat << EOF
$0 [options] RPM_FILES
Create a graph of RPM dependencies in a set of RPM packages.
The output is in dot(https://graphviz.org/doc/info/lang.html) 
directed graph format, and can be displayed or printed using the
dotty graph editor from the graphviz package.  
  -h       print this message
  -v       verbose mode
  -k KEY   if 1 or more "-k" option is present, add all KEYs to a
           KEEP_LIST and keep only dependencies starting with one
           of the KEYs
  -x KEY   if 1 or more "-x" option is present, add all KEYs to a
           REJECT_LIST and reject all dependencies starting with one
           of the KEYs
  -t STR   graph title. Defaults to $TITLE
  -o PATH  output file path (name and directory). Defaults to stdout
Examples:
 $0 -t MyPackage dist/mypackage*rpm > mypackage.dot
 dot -Tsvg mypackage.dot > mypackage.svg
Similar commands:
 rpmgraph (from rpm-devel RPM) is working as well on package files
but is not listing all dependencies, and has no filtering.
 rpmgraph.py (https://codeberg.org/htgoebel/rpmgraph) is using the
RPM db and is Python 2 code.
 dnf repoquery  --tree --requires mypackage-sub_a-3.10.10 --qf "%{name}"
prints too many dependencies 
EOF
}

parse_opts() {
    # Parse options.
    # Sets VERBOSE, KEEP_LIST, REJECT_LIST, OUTFILE
    VERBOSE=
    KEEP_LIST=()
    REJECT_LIST=()
    OUTFILE=/dev/stdout
    TITLE="RPM Dependencies"
    while getopts "v:o:k:x:t:h" option
    do
      case "${option}"
        in
        h) help_msg; exit 0;;
        v) VERBOSE=yes;;
        k) KEEP_LIST+=("$OPTARG");;
        x) REJECT_LIST+=("$OPTARG");;
        o) OUTFILE="$OPTARG";;
        t) TITLE="$OPTARG";;
        *) echo "ERROR: Invalid option -${option} $OPTARG"; help_msg; exit 1;;
      esac
    done
}

get_name() {
    rpm -qp --qf "%{name}" "$1"
}

get_deplist() {
    # Return the RC number, empty for main releases
    # 1 - package file
    rpm -qpR "$1" | cut -d' ' -f1
}

filter_keep() {
    # Read input from stdin line by line
    while IFS= read -r line; do
        if [[ ${#KEEP_LIST[@]} -eq 0 ]]; then
            echo "$line"
        else
            for item in "${KEEP_LIST[@]}"; do
                if [[ "$line" == "$item"* ]]; then
                    echo "$line"
                    break
                fi
            done
        fi
    done
}

filter_reject() {
    # Read input from stdin line by line
    while IFS= read -r line; do
        local match_found=false
        if [[ ${#REJECT_LIST[@]} -ne 0 ]]; then
            for item in "${REJECT_LIST[@]}"; do
                if [[ "$line" == "$item"* ]]; then
                    match_found=true
                    break
                fi
            done
        fi        
        # If no match found, print the line
        if ! $match_found; then
            echo "$line"
        fi
    done
}

print_header() {
    cat << EOF
digraph $TITLE {
  rankdir=LR
//===== Packages:
EOF
}

print_tail() {
    echo "}"
}

print_deps() {
    # 1 - rpm file
    pkg_name=$(get_name "$1")
    for dep in $(get_deplist "$1" | filter_keep | filter_reject); do
        echo "  \"$pkg_name\" -> \"$dep\""
    done
}

_main() {
    # Parse options and adjust parameters
    parse_opts "$@"
    # This needs to be outside to shift the general arglist
    shift $((OPTIND-1))
    print_header > "$OUTFILE"
    for i in "$@"; do
        print_deps "$i" >> "$OUTFILE"
    done
    print_tail >> "$OUTFILE"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _main "$@"
fi

