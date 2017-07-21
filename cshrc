# -*- mode: csh; -*-
# vim: set filetype=csh :

if ( $?LOGIN_ROOT ) then
    set _root=$LOGIN_ROOT
else
    set _root=$HOME
endif

foreach p ( $_root/.cshrc.d/[^_]* )
    source $p
end
