Dotfile Template
################

Installation
============

    git clone <repo>
    cd dotfiles && ./bootstrap.sh

This links the dotfiles into your ``$HOME`` directory.
To install to some other directory (e.g. for testing),
set ``$LOGIN_ROOT`` to the target directory.

What's going on here?
=====================

In general, I find constant confusion about what should go in
which startup file (``.bashrc`` vs. ``.bash_profile`` vs. ``.profile``).
See STARTUP_FILES.rst for my rant/discussion of what the files
are for. In short, profile files are for general settings, and
rc files are solely for things you might see at an interactive
terminal.

In addition, I'm constantly running up against huge files where
different options overwrite others, and it's very hard to puzzle out
exactly where some setting is being overridden.

To that end, this repo is structured so that each startup dotfile
only loops through its associated directory and loads the scripts
within it. Shell-dependent startup files will also load the
default posix startup file (e.g. .bash_profile loads .profile).
In addition, because of the confusion between which files get
loaded based on how you've accessed the shell, the .profile scripts
also load the associated .rc script, if it's an interactive shell.

Stealing a bit from C header files, each startup file defines
an environment variable when it's been loaded, and won't run
if that variable is set. You can override this by setting ``$RELOAD_DOT``.

What goes where?
================

.profile
--------

This is the only file loaded from posix shells, and only on login.
Any environment variables, aliases, and functions that are

a) posix clean
b) expected to always be available

should be placed in a file in ``.profile.d/``.
This is likely to be the case for most settings.

.bash_profile and .zsh_profile
------------------------------

These shell-specific files are loaded in login shells, and will
source ``.profile``.

Only place things in ``.bash_profile.d/`` or ``.zsh_profile.d/``
that you expect to be true for all shells of that type
(e.g. history settings for bash go in ``.bash_profile.d/``).

.shellrc
--------

This isn't really a thing, but it's useful to have a place to put visual
settings, regardless of terminal type. At minimum, put a basic prompt
in ``.shellrc.d/``, expecting it to be overridden by ``.bashrc`` or ``.zshrc``.
Likewise, here's where you set colorization options for ls and diff, since
it's going to be the same regardless of shell.

.bashrc and .zshrc
------------------

These are mainly for visual settings. If you want a fancy prompt,
put it in ``.bashrc.d/`` or ``.zshrc.d/``.

.cshrc
------

I don't use csh, but it's here if you do.
It's written to loop through ``.cshrc.d/``. If you have settings
you only want to run at an interactive terminal, wrap them in

    if ( $?prompt ) then
    ...
    endif

Ordering Files for Priority
===========================

Because files will be loaded in ascii-betical order, higher numbered
(or un-numbered) files in a directory will be loaded after lower
numbered files, and therefore *override* any values set there.
This means that items should be loaded from general to specific or
low to high priority, and that functions used by later stages must be
lower numbered. \[N.B. ascii-betical ordering means that 222 will
load after 22, not after 99.\]

For sanity's sake, I'm numbering ranges as follows

* 00-19
    basic functions/variables used in later stages

* 20-49
    general settings and sane defaults

* 50-89
    site-specific settings

* 90-99
    high priority overrides

* aa-zz
    personal settings
