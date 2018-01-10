# -*- mode: sh; -*-
# vim: set filetype=sh :

in_xprofile=1
_root=${LOGIN_ROOT:-$HOME}
if [ -z "${DEBUG:-}" -a -e "$_root/DEBUG" ]; then  # create a file named DEBUG to verbose
    DEBUG=$(cat "$_root/DEBUG")
    export DEBUG=${DEBUG:-1}
fi
[ "${DEBUG:=0}" -ge 1 ] && echo .bash_profile
[ -e "$_root/.profile" ] && . "$_root/.profile" # load .profile

## Import all bash_profile subs
for p in "${_root}"/.bash_profile.d/*; do
    f=$(basename "$p")
    if [ -f "$p" -a "$f" = "${f#_}" ]; then   # ignore files that start with _
        [ "${DEBUG:-0}" -ge 2 ] && echo "$p"
        . "$p"
    fi
done

# Run .bashrc if it's an interactive shell
[ -z "${in_rc:-}" -a -t 0 -a -e "$_root/.bashrc" ] && . "$_root/.bashrc"

unset in_xprofile
