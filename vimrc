set nocompatible

" OS detection [http://vi.stackexchange.com/a/2577]
    " g:os == 'Darwin' -> OSX
    " g:os == 'Linux'  -> Linux
    " g:os == 'Windows -> Windows
if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif

" Print options
set printfont=Fira\ Code:h10

" ---- Vundle/Plugins
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" bundles
Plugin 'VundleVim/Vundle.vim'
" Plugin 'scrooloose/nerdtree' " file browser            
Plugin 'klen/python-mode' " python mode :help pymode
Plugin 'pythoncomplete' " python omnicompletion
Plugin 'vim-perl/vim-perl' " perl modes :help 
Plugin 'c9s/perlomni.vim' " perl omnicompletion
" Plugin 'scrooloose/nerdtree' " pretty directory trees
Plugin 'vim-scripts/n3.vim' " Notation-3 RDF syntax
Plugin 'altercation/vim-colors-solarized' " solarized color sets

call vundle#end()
" -- other config

" UTF-8
set enc=utf-8
" set fileencoding=utf-8 " -- forces UTF-8, fails on read-only files
setglobal fenc=utf-8 " new files are utf-8
if g:os == 'Darwin'
    set fileencodings=ucs-bom,utf8,macroman
else
    set fileencodings=ucs-bom,utf8,default
endif

" indent settings
filetype indent on
set autoindent
" set smartindent
set tabstop=4
set shiftwidth=4
set expandtab

" set Tab and S-Tab to indent, unindent
nmap <Tab> a<C-t><Esc>
nmap <S-Tab> a<C-d><Esc>
" Tab is already indent
imap <S-Tab> <C-d>
vmap <Tab> :><CR>gv
vmap <S-Tab> :<<CR>gv

" show tabs as blue underlines
syntax match Tab /\t/
hi Tab gui=underline guifg=blue ctermfg=blue
set list

set showmatch
set number
set virtualedit=all

" NerdTree Settings
  " start tree if no files
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
  " Ctrl-N to open tree
" map <C-n> :NERDTreeToggle<CR>
  " Close window if only NERDTree is open on close of others
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Language Settings

" -- requires vim-perl
let perl_fold=0
let perl_include_POD=1
set foldlevelstart=20
" Note, perl automatically sets foldmethod in the syntax file
autocmd Syntax c,cpp,vim,xml,html,xhtml setlocal foldmethod=syntax
autocmd Syntax c,cpp,vim,xml,html,xhtml,perl normal zR

au BufNewFile,BufRead *.cwl set filetype=yaml

" -- requires python-mode
let g:pymode_python = 'python3'
let g:pymode_options_max_line_length = 132
let g:pymode_indent = 1


" Colorscheme
" -- requires solarized
syntax enable
if has('gui_running')
    set background=light
else
    set background=dark
    if g:os == 'Darwin'
        let g:solarized_termcolors=256 " hack to give decent colors on mac terminal   
    endif
endif
" let g:solarized_contrast="high"
colorscheme solarized


" Printing
set popt=paper:letter,duplex:long
runtime ftplugin/man.vim
set printoptions=number:y

" block swap and undo for huge files
let g:SaveUndoLevels = &undolevels
let g:BufSizeThreshold = 1000000
if has("autocmd")
    " Store preferred undo levels
    au VimEnter * let g:SaveUndoLevels = &undolevels
    " Don't use a swap file for big files
    au BufReadPre * if getfsize(expand("<afile>")) >= g:BufSizeThreshold | setlocal noswapfile | endif
    " Upon entering a buffer, set or restore the number of undo levels
    au BufEnter * if getfsize(expand("<afile>")) < g:BufSizeThreshold | let &undolevels=g:SaveUndoLevels | hi Cursor term=reverse ctermbg=black guibg=black | else | set undolevels=-1 | hi Cursor term=underline ctermbg=red guibg=red | endif
endif

" paste-mode from http://stackoverflow.com/questions/5585129/pasting-code-into-terminal-window-into-vim-on-mac-os-x
if &term =~ "xterm.*" || &term =~ "screen.*"
    let &t_ti = &t_ti . "\e[?2004h"
    let &t_te = "\e[?2004l" . &t_te
    function XTermPasteBegin(ret)
        set pastetoggle=<Esc>[201~
        set paste
        return a:ret
    endfunction
    map <expr> <Esc>[200~ XTermPasteBegin("i")
    imap <expr> <Esc>[200~ XTermPasteBegin("")
    vmap <expr> <Esc>[200~ XTermPasteBegin("c")
    cmap <Esc>[200~ <nop>
    cmap <Esc>[201~ <nop>
endif
