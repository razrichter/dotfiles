# -*- mode: zsh; -*-
# vim: set filetype=zsh :

if [ -t 0 ]; then  # only run if interactive shell
    _root=${LOGIN_ROOT:-$HOME}
    if [ -z "${__DOT_ZSHRC:-}" -o -n "${RELOAD_DOT:-}" ]; then  # run only once
        [ -n "${DEBUG:=}" ] && echo .zshrc

        [ -e "$_root/.shellrc" ] && . "$_root/.shellrc"  # load generic shellrc

        ## Import all zshrc subs
        for p in "${_root}"/.zshrc.d/*; do
            f=$(basename "$p")
            if [ -f "$p" -a "$f" = "${f#_}" ]; then   # ignore files that start with _
                [ "${DEBUG:-}" -ge 2 ] && echo "$p"
                . "$p"
            fi
        done

        export __DOT_ZSHRC=1
    fi
fi
