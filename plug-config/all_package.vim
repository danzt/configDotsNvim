
call plug#begin('~/.vim/plugged')
" Temas
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'itchyny/lightline.vim'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'artanikin/vim-synthwave84'
Plug 'yardnsm/vim-import-cost', { 'do': 'npm install' }
Plug 'codota/tabnine-vim'
Plug 'luochen1990/rainbow'

"IDE
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'easymotion/vim-easymotion'
Plug 'scrooloose/nerdtree'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'editor-bootstrap/vim-bootstrap-updater'
Plug 'tpope/vim-rhubarb' " required by fugitive to :Gbrowse
Plug 'jistr/vim-nerdtree-tabs'
Plug 'tpope/vim-commentary'
Plug 'vim-scripts/grep.vim'
Plug 'vim-scripts/CSApprox'
Plug 'Raimondi/delimitMate'
Plug 'majutsushi/tagbar'
Plug 'dense-analysis/ale'
Plug 'wakatime/vim-wakatime'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'leafOfTree/vim-vue-plugin'
Plug 'kyoz/purify', { 'rtp': 'vim' }
Plug 'kaicataldo/material.vim', { 'branch': 'main' }
Plug 'APZelos/blamer.nvim'
Plug 'jvanja/vim-bootstrap4-snippets'
Plug 'mattn/emmet-vim'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'mlaursen/vim-react-snippets'
Plug 'voldikss/vim-floaterm'
Plug 'vim-scripts/HTML-AutoCloseTag'
Plug 'Yggdroot/indentLine'
Plug 'jiangmiao/auto-pairs'
Plug 'andymass/vim-matchup'
Plug 'yardnsm/vim-import-cost', { 'do': 'npm install' }
Plug 'mileszs/ack.vim'
Plug 'romgrk/barbar.nvim'
Plug 'zivyangll/git-blame.vim'
Plug 'liuchengxu/vim-clap', {'do': function('clap#helper#build_all') }


" Vim-Session
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'
Plug 'mox-mox/vim-localsearch'

"" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" javascript
Plug 'jelera/vim-javascript-syntax'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'maksimr/vim-jsbeautify'
"Plug 'sbdchd/neoformat'
Plug 'https://github.com/leafgarland/typescript-vim'

" php
Plug 'phpactor/phpactor', {'for': 'php', 'do': 'composer install --no-dev -o'}
Plug 'stephpy/vim-php-cs-fixer'

"Auto Import

" svelte
Plug 'leafOfTree/vim-svelte-plugin'


" typescript
Plug 'leafgarland/typescript-vim'



" commentary
Plug 'preservim/nerdcommenter'

" Stable version of coc
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" " Keeping up to date with master
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

" Git
Plug 'airblade/vim-gitgutter'
Plug 'xuyuanp/nerdtree-git-plugin'
Plug 'jreybert/vimagit'
Plug 'Shougo/denite.nvim'
Plug 'chemzqm/denite-git'
Plug 'tpope/vim-fugitive'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

"Tmux themes
Plug 'prabirshrestha/async.vim'
Plug 'wellle/tmux-complete.vim'

"Plug Laravel
Plug 'noahfrederick/vim-laravel'
Plug 'sunzhongwei/vim-laravel-snippets'
Plug 'jwalton512/vim-blade'

"Busqueda de Archivos
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'


if has('nvim') || has('patch-8.0.902')
	Plug 'mhinz/vim-signify'
else
	Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif

Plug 'ap/vim-css-color', {
  \ 'for': [
    \ 'html',
    \ 'css',
    \ 'scss',
    \ 'sass',
    \ 'less'
    \ ] }

Plug 'Valloric/MatchTagAlways' "------- Always highlights the XML/HTML tags that enclose your cursor location
Plug 'alvan/vim-closetag' "--------------------------------- Auto close html tag
Plug 'tmsvg/pear-tree' "------------------------------------- Auto pair brackets
Plug 'tpope/vim-surround' "--------------------------------------- Auto surround
Plug 'tpope/vim-commentary' "------------------------------- Comment code faster
Plug 'tpope/vim-repeat' "------------------------------ dot repeat with pluggins
Plug 'mg979/vim-visual-multi' "--------------------------------- Multiple Cursor

" Vim Script {{{
Plug 'kyazdani42/nvim-web-devicons'
Plug 'folke/lsp-trouble.nvim'
"""}}}





" BEAUTIFY CODE {{{

Plug 'FooSoft/vim-argwrap' "------ Wrap and unwrap function args, list, dicts...
Plug 'prettier/vim-prettier', {
  \ 'do': 'npm install',
  \ 'branch': 'release/1.x',
  \ 'for': [
    \ 'javascript',
    \ 'typescript',
    \ 'css',
    \ 'less',
    \ 'sass',
    \ 'scss',
    \ 'json',
    \ 'markdown',
    \ 'html' ] }

" }}}
"
" UTILS {{{
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'NLKNguyen/copy-cut-paste.vim' "---------------- Copy, Paste with Clipboard
Plug 'KabbAmine/vCoolor.vim' "------------------------------------- Color picker
Plug 'guns/xterm-color-table.vim'
Plug 'RRethy/vim-illuminate' "--- Auto highlight other uses of word under cursor
Plug 'voldikss/vim-search-me' "------------------------ Search google within vim
if has('nvim')
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/defx.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
"}}}

" Searching{{{

Plug 'voldikss/vim-search-me' "------------------------ Search google within vim

" }}}

"Test Plug New!
 Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'kabouzeid/nvim-lspinstall'
  Plug 'glepnir/lspsaga.nvim'
  Plug 'hrsh7th/nvim-compe'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/nvim-treesitter-textobjects'

  Plug 'glepnir/galaxyline.nvim', { 'branch': 'main' }
  Plug 'kyazdani42/nvim-web-devicons'  " needed for galaxyline icons

  Plug 'NLKNguyen/papercolor-theme'
  Plug 'nikvdp/neomux'

  Plug 'tpope/vim-ragtag'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-unimpaired'

  Plug 'tpope/vim-eunuch'
  Plug 'tpope/vim-fugitive'

  Plug 'tomtom/tcomment_vim'
call plug#end()


