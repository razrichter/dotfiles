Shell Startup Files
###################

TLDR;
=====

* unless absolutely necessary, never create anything but \*profile and \*rc files

* because GUI terminal windows on mac are login shells, but on linux are
  non-login shells, it's important to source \*rc files from \*profile files.

* there's a lot of weirdness with regard to interactions of ssh options and
  whether or not there's a command in the ssh, so it's also important to
  make sure that \*profile files get sourced from \*rc files

* Extended posix shells' (bash and zsh) \*profile files should source a
  .profile file that contains common settings, and should otherwise
  only contain shell-specific settings.

* ``\*profile`` files should contain settings that are used
  all the time, such as environment variables and shell options

* ``\*rc`` files should contain things that affect the interactive
  terminal, such as prompts. The exception being (t)csh, where cshrc is used
  for all shells and subshells, and where interactive settings should be
  tested for and skipped in non-interactive shells.

* I'm a bash user, so zsh is largely untouched, and csh was right
  out when I couldn't redirect STDOUT and STDERR separately.

Definitions
===========

Login shell:
    the initial shell started in a session. As the name implies, it's going to
    happen as you log in on Linux or BSD, either through the GUI login
    (so you'll never see that shell) or by SSH/etc.
    On MacOS, every terminal window you open is a login shell (go figure),
    and the GUI *does not* have any of the environment variables, etc set,
    so GUI programs that don't start a shell don't know about any of
    your personalizations.

Non-login shell:
    every other shell. On Linux/BSD, that's every subshell (e.g. script)
    and terminal window you open in the GUI. On MacOS, since the new
    terminal windows are login shells, it'll only happen for subshells.

Interactive shell:
    if the shell is reading commands from a tty (instead of a script),
    it's interactive. In practice, that translates to
    being able to type at the shell.


Files Read by Program and Type
==============================

In these tables, *L* stands for login shell, *N* for a non-login interactive
shell, and *S* for a non-login non-interactive shell (generally a script).
For any one condition, the order of files is determined by letter
(i.e. A before B ). If (as in bash), only the first of a series of files
will be run, then that will be specified by a number (e.g. B1, B2 ). If a
name is in all-caps (e.g. $BASH_ENV), this refers to a file specified in an
environment variable (presumably set in the login shell startup files).

In general, any exported settings from the login shell *should* be available
to the non-login shells and to non-interactive shells.

POSIX shell (sh)
----------------

This is the base Bourne shell, as well as deliberate workalikes like ash and
dash. Ksh, Bash, and Zsh are all extensions of the posix shell, and
have compatibility modes where these variables are used instead/in addition to
their primary ones. In many linux distributions, by default, /bin/sh is
actually bash in compatibility mode. In some, and on BSD, it's ash or dash.

For portability, try as much as possible to write scripts in POSIX-clean
shell syntax. I find that if I can't, I generally should move to a language like
python or perl.

See the `official posix shell documentation <http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html>`_
for details of its specification. For learning, I strongly recommend
`Unix Power Tools <http://shop.oreilly.com/product/9780596003302.do>`_.

================ ===== ===== =====
  File             L     N     S
================ ===== ===== =====
  /etc/profile     A
  ~/.profile       B
  $ENV                         A
================ ===== ===== =====

Bash
----

Bash is the GNU Bourne-Again shell. It's the default shell on most linux and older MacOS
machines. You can see the `official bash documentation <https://www.gnu.org/software/bash/manual/bashref.html>`_
but the TLDP docs (`Basic <http://www.tldp.org/LDP/Bash-Beginners-Guide/html/index.html>`_
and `Advanced Scripting <http://www.tldp.org/LDP/Bash-Beginners-Guide/html/index.html>`_)
are better guides for learning.

=========================== ===== ===== =====
  File                        L     N     S
=========================== ===== ===== =====
  /etc/profile                A
  ~/.bash_profile             B1
  ~/.bash_login               B2
  ~/.profile                  B3
  /etc/bash.bashrc                  A
  ~/.bashrc                         B
  $BASH_ENV                               A
  ~/.bash_logout        \*    Y
  /etc/bash.bash_logout \*    Z
=========================== ===== ===== =====

\* The logout files are run when a login shell is exiting.

Zsh
---

Zsh is the default shell for macOS, a really popular shell for interactive use, and has
*tons* of fancy configuration available (see `Oh-My-Zsh <https://github.com/robbyrussell/oh-my-zsh>`_
for a framework for these). You can also read the
`zsh official documentation <http://zsh.sourceforge.net/>`_.

================== ===== ===== =====
  File               L     N     S
================== ===== ===== =====
  /etc/zshenv        A     A     A
  ~/.zshenv          B     B     B
  /etc/zprofile      C1
  /etc/profile       C2
  ~/.zprofile        D1
  ~/.profile         D2
  /etc/zshrc         E     C
  ~/.zshrc           F     D
  /etc/zlogin        G
  ~/.zlogin          H
  ~/.zlogout   \*    Y
  /etc/zlogout \*    Z
================== ===== ===== =====

\* The logout files are run when a login shell is exiting.

TCsh
----

The T-Cshell is an improved version of the C-shell, which was the
original shell for the BSD systems. The syntax is *not* compatible
with POSIX-based shells, and it has `many idiosyncracies <http://www.grymoire.com/Unix/CshTop10.txt>`_
that make is non-ideal for writing shell scripts. You can read the
`tcsh manual <http://www.tcsh.org/tcsh.html/top.html>`_.

================== ===== ===== =====
  File               L     N     S
================== ===== ===== =====
  /etc/csh.cshrc     A     A
  /etc/csh.login     B
  ~/.tcshrc          C1    B1
  ~/.cshrc           C2    B2
  ~/.login           D
================== ===== ===== =====

Note that Csh is identical, except for not looking for ~/.tcshrc.


Testing for various shell types
===============================

- Login shell

    - ``if shopt -q login_shell``

        - only bash

    - ``if [[ -o login ]]``

        - only zsh

    - ``if($?loginsh) then``

        - only tcsh (csh does not support this)

- Interactive shell

    - ``if [ -t 0 ]`` # -- is STDIN (filehandle 0) attached to a TTY?

        - all posix shells

    - ``[ -n ${PS1:-} ]`` # -- is prompt set (normally done in /etc/(bash|zsh)rc)

        - bash and zsh

    - ``[[ $- == *i* ]]`` # -- check shell flags for an if

        - bash and zsh

    - ``case $- in *i*) echo I ;; *) echo N ;; esac`` # same, but in a case statement

        - all posix shells

    - ``if($?prompt) then``

        - csh and tcsh


SSH weirdness
=============

* If you simply run ``ssh <hostname>``, it will start a new interactive login shell.

* However, if you run ``ssh <hostname> <command>``, it will neither be interactive or
  a login shell, so only \*rc scripts will run (except, of course, .shellrc, since
  that's not actually a thing).

* You can make it an interactive shell with ``ssh -t <hostname> <command>``. However,
  it's still not a login shell, so the \*profile scripts won't run.

* Note that, if you are running a command, no login scripts will be loaded.
  To get around that, you can run the command prefixed with ``$SHELL -li -c '<command>'``.
  However, do note that, any rc files will run *first*, before the login shell
  is started.

