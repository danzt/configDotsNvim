
"let g:onedark_termcolors=128

"set background=dark
":silent! colorscheme purify

"syntax on " This is required

let g:onedark_termcolors=256
:silent! colorscheme purify

let g:airline_theme='purify'


colorscheme purify "--------------------------------- Set onedark theme
hi Normal guibg=#252834 ctermbg=234 "---- Place this after you set the colorscheme


" AIRLINE {{{

let g:airline_theme='synthwave84' "--------------------------- Set status bar's theme
let g:airline_powerline_fonts = 1 "----------- Just work with patched NERD fonts
let g:airline_section_c = '%t' "--filename "-------------- Only show file's name
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]' "- Hide format type

let g:airline#extensions#tabline#enabled = 1 "------------------- Enable tabline
let g:airline#extensions#tabline#fnamemod = ':t' "--- Just show file name in tab
let g:airline#extensions#tabline#enabled=1 "--------- Buffers at the top as tabs
let g:airline#extensions#tabline#show_tab_type=1 "---------- Don't show tab type

" }}}
"
"


" INDENT LINE {{{

let g:indentLine_char = '┆'

augroup indentLine_config
    autocmd!
    autocmd InsertEnter *.json setlocal concealcursor=
    autocmd InsertLeave *.json setlocal concealcursor=inc
augroup END

" }}}



" TREE PAIRS {{{

let g:pear_tree_pairs = {
  \ '(':    {'closer': ')'},
  \ '[':    {'closer': ']'},
  \ '{':    {'closer': '}'},
  \ "'":    {'closer': "'"},
  \ '"':    {'closer': '"'},
  \ '/*':   {'closer': '*/'},
  \ '<!--': {'closer': '-->'}
  \ }

let g:pear_tree_repeatable_expand = 0

" }}}



" EMMET {{{

" Enable just for html, css
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

let g:user_emmet_leader_key=',' " Trigger emmet with ,,

autocmd FileType html,css,scss,sass,less,typescript EmmetInstall " Support files

" }}}

" VIM-ILLUMINATE {{{

hi link illuminatedWord Visual

" }}}

" VCOOLOR {{{

let g:vcoolor_map        = '<localleader>c'
let g:vcool_ins_rgba_map = '<localleader>C'

" }}}

let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#252834'

