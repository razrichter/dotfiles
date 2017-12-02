# -*- mode: sh; -*-
# vim: set filetype=sh :

if [ -t 0 ]; then  # only run if interactive shell
    _root=${LOGIN_ROOT:-$HOME}
    if [ -z "${__DOT_BASHRC:-}" -o -n "${RELOAD_DOT:-}" ]; then  # run only once
        [ -n "${DEBUG:=}" ] && echo .bashrc
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
fi
