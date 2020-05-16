" https://github.com/tpope/vim-pathogen
execute pathogen#infect()

" Use F1 to toggle highlighting of search results
nnoremap <F1> :set invhls hls?<CR>

set foldenable
set foldmethod=syntax
" Show the first two levels of nesting by default. This usually provides a
" convenient overview without overloading the human
set foldnestmax=2
set foldlevel=2

let loaded_matchparen = 1

set tabstop=4
set shiftwidth=4
"set linebreak
set textwidth=0
" No right scrollbar
set guioptions-=r
" No menubar
set guioptions-=m
" No toolbar
set guioptions-=T

set nocompatible        " Use Vim defaults
set bs=2                " Allow backspacing over everything in insert mode
set ai                  " Always set auto-indenting on
set viminfo=            " Do not keep a viminfo file
set ruler               " Show the cursor position all the time
set relativenumber      " Relative line numbering
set number              " Also show current line number along with relativenumber

" When auto-completing files, do it a way similar to bash (show a list of all
" matching names
set wildmode=longest,list
set wildignorecase

" Added to default to high security within Gentoo. Fixes bug #14088.
" Modified 07 Oct 2003 by agriffis from "modelines=0" to "nomodeline"
" according to conversation on vim devel ML:
" http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=212696
" http://article.gmane.org/gmane.editors.vim.devel/4410
set nomodeline

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
  set fileencodings=utf-8,latin1
endif

" Enable 256 colors
set t_Co=256

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Disable the use of mouse and don't even try connecting to the X server
set mouse-=a
set clipboard=exclude:.*

" Enable plugin-provided filetype settings, but only if the ftplugin
" directory exists (which it won't on livecds, for example).
if isdirectory(expand("$VIMRUNTIME/ftplugin"))
  filetype plugin on
endif

" Uncomment the next line (or copy to your ~/.vimrc) for plugin-provided
" indent settings. Some people don't like these, so we won't turn them on by 
" default.
filetype indent on

set background=dark
colorscheme darcula
" Don't fill the background
hi Normal ctermbg=NONE
