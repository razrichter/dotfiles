# -*- mode: sh; -*-
# vim: set filetype=sh :

in_rc=1

if [ -t 0 ]; then  # only run if interactive shell
    _root=${LOGIN_ROOT:-$HOME}
    [ -z "${in_xprofile:-}" -a -e "${_root}/.bash_profile" ] && . "${_root}/.bash_profile"
    [ "${DEBUG:=0}" -ge 1 ] && echo .bashrc

    [ -e "$_root/.shellrc" ] && . "$_root/.shellrc"  # load generic shellrc

    ## Import all bashrc subs
    for p in "${_root}"/.bashrc.d/*; do
        f=$(basename "$p")
        if [ -f "$p" -a "$f" = "${f#_}" ]; then   # ignore files that start with _
            [ "${DEBUG:-0}" -ge 2 ] && echo "$p"
            . "$p"
        fi
    done

    export __DOT_BASHRC=1
fi
unset in_rc
