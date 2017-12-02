# -*- mode: sh; -*-
# vim: set filetype=sh :
_root=${LOGIN_ROOT:-$HOME}
if [ -e "$_root/DEBUG" ]; then  # create a file named DEBUG to verbose
    DEBUG=$(cat "$_root/DEBUG")
    export DEBUG=${DEBUG:-1}
fi
if [ -z "${__DOT_PROFILE:-}" -o -n "${RELOAD_DOT:-}" ]; then  # run only once
    [ -n "${DEBUG:=}" ] && echo .profile

    ## Import all profile subs
    for p in "${_root}"/.profile.d/*; do
        f=$(basename "$p")
        if [ -f "$p" -a "$f" = "${f#_}" ]; then   # ignore files that start with _
            [ "${DEBUG:-0}" -ge 2 ] && echo "$p"
            . "$p"
        fi
    done

    # Run .shellrc if it's an interactive shell
    [ -t 0 -a -e "$_root/.shellrc" ] && . "$_root/.shellrc"

    export __DOT_PROFILE=1
fi
