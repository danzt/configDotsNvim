set number
set laststatus=2
syntax enable
set ruler
set relativenumber
set tabstop=4
set expandtab
set shiftwidth=4
set autoindent
set gcr=a:blinkon0
"" Status bar

set laststatus=2
":set guioptions-=m "-------------------------------------------- Remove menu bar
:set guioptions-=T "--------------------------------------------- Remove toolbar
":set guioptions-=r "------------------------------- Remove right-hand scroll bar
":set guioptions-=L "-------------------------------- Remove left-hand scroll bar
set colorcolumn=130 "---------------------------------------- 80 line column show
set nospell "-------------------------------------------------- Disable spelling
set formatoptions-=t "--------------- Do not automatically wrap text when typing
set listchars=tab:\|\ ,trail:▫
set formatoptions=tcqronj "-------------------- Set vims text formatting options
set title "-------------------------------------- Let vim set the terminal title
set updatetime=500 "-------------------------------- Redraw the status bar often
"set listchars=tab:•\ ,trail:•,extends:»,precedes:« "-- Unprintable chars mapping
set showcmd	"--------------------------------------- Display incomplete commands
set termencoding=utf-8 "------------------------------------------- Always utf-8
set fileencoding=utf-8
set hid "---------------------------------- Buffer becomes hidden when abandoned
set shortmess+=c
set cmdheight=1 "--------------------------- Just need one line for command line
set laststatus=2 "-------------------------------------- Always show status line
set showtabline=2 "----------------------------------------- Always show tabline
set noshowmode "--------------------------- Hide default mode text (e.g. INSERT)
set display+=lastline "--------------------- As must as possible of the lastline
set signcolumn=yes "---------------------------------- Always open gutter column

" TAB, INDENT {{{

"set expandtab "------------------------------------------ Add tab in insert mode
"set smarttab
"filetype indent on "------------------------------------- Turn on default indent
"set autoindent
"set smartindent

" }}}

" ENABLE MOUSE {{{

if has('mouse')
    set mouse=a "----------------------------- Allow use mouse, possible in nvim
endif

" }}} 



syntax on
"" Use modeline overrides
set modeline
set modelines=10
"":set nopaste	
set encoding=UTF-8
set ts=2 sw=2 et
set statusline=%{kite#statusline()}%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\
"set clipboard=unnamedplus
"":filetype indent on 
"":set filetype=html
"":set smartindent 
set nowrap
set spell

"set ignorecase      " ignore case
"set smartcase     " but don't ignore it, when search string contains uppercase letters
"set nocompatible
"set incsearch        " do incremental searching
"set visualbell
"set hlsearch
"set virtualedit=all
"set backspace=indent,eol,start " allow backspacing over everything in insert mode

