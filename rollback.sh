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
$(basename "$0") <datestamp> [<root_dir>]
removes the links created by bootstrap in <root_dir>, and restores the files
with the suffix <datestamp>.orig
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
_COMMAND_LIST
)

main() {
    # option parsing
    while getopts "h" opt; do
        case $opt in
            h)
                usage >&2
                exit 0
            ;;
        esac
    done
    shift $((OPTIND-1))

    datestamp=${1}
    root=${2:-"$PWD"}
    [ ! -d "$root" ] && mkdir -p "$root"
    for f in $commands; do
        source="$bindir/$f"
        target="${root}/.${f}"
        backup="${root}/.${f}.${datestamp}.orig"
        if [ -e "$target" ]; then
            if samepath "$source" "$target" ; then
                rm "$target"
                if [ -e "$backup" ]; then
                    mv "$backup" "$target"
                fi
            else
                echo "$target is not a link to repo. Leaving..." >&2
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
realpath() {
    # realpath $path -- prints the link-resolved path
    path=$(abspath "${1:-$PWD}")
    while [ -L "$path" ]; do
        path=$(abspath "$(readlink "$path")" "$(dirname "$path")")
    done
    if [ -d "$path" ]; then
        realpath=$(cd "$path" && /bin/pwd -P)
    else
        realdir="$(cd "$(dirname "$path")" && /bin/pwd -P)"
        realpath="$realdir/$(basename "$path")"
    fi
    echo "$realpath"
}

samepath() {
    # samepath $patha $pathb -- returns true iff $patha and $pathb are the same entity on the filesystem (i.e. links or symbolic paths)
    patha_inode=$(stat -f '%i' "$(realpath "$1")" 2>/dev/null)
    pathb_inode=$(stat -f '%i' "$(realpath "$2")" 2>/dev/null)
    [ "$patha_inode" = "$pathb_inode" ]
}

main "$@"
