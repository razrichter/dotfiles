# -*- mode: zsh; -*-
# vim: set filetype=zsh :

in_rc=1

if [ -t 0 ]; then  # only run if interactive shell
    _root=${LOGIN_ROOT:-$HOME}
    [ -z "${in_xprofile:-}" -a -e "${_root}/.zsh_profile" ] && . "${_root}/.zsh_profile"
    [ "${DEBUG:=0}" -ge 1 ] && echo .zshrc

    [ -e "$_root/.shellrc" ] && . "$_root/.shellrc"  # load generic shellrc

    ## Import all zshrc subs
    for p in "${_root}"/.zshrc.d/*; do
        f=$(basename "$p")
        if [ -f "$p" -a "$f" = "${f#_}" ]; then   # ignore files that start with _
            [ "${DEBUG:-0}" -ge 2 ] && echo "$p"
            . "$p"
        fi
    done

fi

unset in_rc
