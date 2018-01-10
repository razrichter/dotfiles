# -*- mode: sh; -*-
# vim: set filetype=sh :

in_profile=1
_root=${LOGIN_ROOT:-$HOME}
if [ -z "${DEBUG:-}" -a -e "$_root/DEBUG" ]; then  # create a file named DEBUG to verbose
    DEBUG=$(cat "$_root/DEBUG")
    export DEBUG=${DEBUG:-1}
fi
[ "${DEBUG:=0}" -ge 1 ] && echo .profile

## Import all profile subs
for p in "${_root}"/.profile.d/*; do
    f=$(basename "$p")
    if [ -f "$p" -a "$f" = "${f#_}" ]; then   # ignore files that start with _
        [ "${DEBUG:-0}" -ge 2 ] && echo "$p"
        . "$p"
    fi
done

# Run .shellrc if it's an interactive shell
[ -z "${in_xprofile:-}" -a -z "${in_rc:-}" -a -t 0 -a -e "$_root/.shellrc" ] && . "$_root/.shellrc"

unset in_profile
