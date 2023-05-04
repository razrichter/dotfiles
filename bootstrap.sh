#!/bin/sh
# -*- mode: sh; -*-
# vim: set filetype=sh :
set -u # no uninitialized
set -e # exit on error ( use "|| true" or wrap in "set +e" "set -e" to block )
set -o pipefail # also exit if error in piped command -- must disable for acceptable errors
IFS=$(printf '\n\t') # spaces don't split items
bindir=$(cd "$(dirname "$0")" && pwd)

usage () {
    cat <<_USAGE
$(basename "$0") [-n] [<dir>]
Links and hides the dotfiles into the
given directory, or \$HOME, if not otherwise specified.
Options:
    -n : dry-run (only show files that would be changed)
_USAGE
}


commands=$(cat <<_COMMAND_LIST
profile
profile.d
shellrc
shellrc.d
bash_profile
bash_profile.d
bashrc
bashrc.d
zsh_profile
zsh_profile.d
zshrc
zshrc.d
cshrc
cshrc.d
logout
logout.d
inputrc
hushlogin
dircolors
gitconfig
gitignore
vimrc
gvimrc
vim
_COMMAND_LIST
)

main() {
    # option parsing
    local dryrun=
    while getopts "hn" opt; do
        case $opt in
            h)
                usage >&2
                exit 0
            ;;
            n) dryrun=1;
        esac
    done
    shift $((OPTIND-1))

    root=${1-"$HOME"}
    [ ! -d "$root" ] && mkdir -p "$root"
    timestamp=$(date -u +'%Y-%m-%dT%H-%m-%SZ')
    for f in $commands; do
        p=$(abspath "$bindir/$f")
        t="$root/.$f"
        if [ -e "$p" ]; then
            if [ "1" = "${dryrun:-}" ]; then
                [ -e "$t" ] && echo "$t"
            else
                if [ -e "$t" ]; then  #  move existing files out of the way
                    mv "$t" "$t.$timestamp.orig"
                fi
                ln -s "$p" "$t"
            fi
        else
            echo "Couldn't find $f" >&2
        fi
    done

}

abspath() {
    # abspath $path -- prints absolute path
    local ABSFILE="${1}"
    [ -z "$ABSFILE" ] && return 1
    ABSFILE=${ABSFILE%/}  # remove final /, if there
    {
    if [ -z "$ABSFILE" ]; then
        echo "/"
        return 0
    elif [ "$ABSFILE" = "." ]; then
        echo "$PWD"
    elif [ "${ABSFILE#/}" = "${ABSFILE}" ]; then
        echo "${PWD}/${ABSFILE}"
    else
        echo "${ABSFILE}"
    fi
    } | sed '
    s~^\./~~
    :a
    s;/\./;/;g
    s;//;/;g
    s;/[^/][^/]*/\.\./;/;g
    ta
    s~/[^/][^/]*/\.\.$~/~
    '
}

main "$@"
