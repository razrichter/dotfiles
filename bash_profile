# -*- mode: sh; -*-
# vim: set filetype=sh :

_root=${LOGIN_ROOT:-$HOME}
if [ -e "$_root/DEBUG" ]; then  # create a file named DEBUG to verbose
    DEBUG=$(cat "$_root/DEBUG")
    export DEBUG=${DEBUG:-1}
fi
if [ -z "${__DOT_BASH_PROFILE:-}" -o -n "${RELOAD_DOT:-}" ]; then  # run only once
    [ -n "${DEBUG:=}" ] && echo .bash_profile
    [ -e "$_root/.profile" ] && . "$_root/.profile" # load .profile

    ## Import all bash_profile subs
    for p in "${_root}"/.bash_profile.d/*; do
        f=$(basename "$p")
        if [ -f "$p" -a "$f" = "${f#_}" ]; then   # ignore files that start with _
            [ "${DEBUG:-}" -ge 2 ] && echo "$p"
            . "$p"
        fi
    done

    # Run .bashrc if it's an interactive shell
    [ -t 0 -a -e "$_root/.bashrc" ] && . "$_root/.bashrc"

    export __DOT_BASH_PROFILE=1
fi
