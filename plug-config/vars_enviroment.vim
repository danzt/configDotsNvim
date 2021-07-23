
let mapleader= " "

let g:NERDTreeChDirMode = 1

let g:WebDevIconsUnicodeDecorateFolderNodes =1
let g:DevIconsEnableFoldersOpenClose = 1
let g:WebDevIconsNerdTreeGitPluginForceVAlign = 1
let g:webdevicons_enable_nerdtree = 1
"
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'✹',
                \ 'Staged'    :'✚',
                \ 'Untracked' :'✭',
                \ 'Renamed'   :'➜',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'✖',
                \ 'Dirty'     :'✗',                
                \ 'Ignored'   :'☒',
                \ 'Clean'     :'✔︎',
                \ 'Unknown'   :'?',
                \ }

let g:NERDTreeGitStatusUseNerdFonts = 1 " you should install nerdfonts by yourself. default: 0
"let g:NERDTreeGitStatusUntrackedFilesMode = 'all' " a heave feature too. default: normal
let g:NERDTreeGitStatusShowIgnored = 1 " a heavy feature may cost much more time. default: 0
"let g:NERDTreeGitStatusUntrackedFilesMode = 'all' " a heave feature too. default: normal
"let g:NERDTreeGitStatusShowClean = 1 " default: 0
"let g:NERDTreeGitStatusConcealBrackets = 1 " default: 0
"
let g:easygit_enable_command = 1

let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'


" vim-airline
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1

let g:airline#extensions#tabline#enabled = 1 " Mostrar los Buffers que estan abiertos
let g:airline#extensions#tabline#fnamemod = ':t' " Monstar el nomber de las pestanas
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

let g:airline_powerline_fonts = 1 " Fuentes y simbolos

let g:indentLine_fileTypeExclude = ['text', 'sh', 'help', 'terminal']
let g:indentLine_bufNameExclude = ['NERD_tree.*', 'term:.*']

let g:tmuxcomplete#asyncomplete_source_options = {
            \ 'name':      'tmuxcomplete',
            \ 'whitelist': '*',
            \ 'config': {
            \     'splitmode':      'words',
            \     'filter_prefix':   1,
            \     'show_incomplete': 1,
            \     'sort_candidates': 0,
            \     'scrollback':      0,
            \     'truncate':        0
            \     }
            \ }



let Grep_Default_Options = '-IR'
let Grep_Skip_Files = '*.log *.db'
let Grep_Skip_Dirs = '.git node_modules'

"let g:indent_guides_enable_on_vim_startup = 1 "Poner el indent por default de airline


let g:indentLine_enabled = 1


let g:coc_fzf_preview = ''
let g:coc_fzf_opts = []


let g:lightline = {
      \ 'colorscheme': 'synthwave84',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ] ],
      \   'right': [['kitestatus'], ['filetype', 'percent', 'lineinfo'], ['gitbranch']]
      \ },
      \ }


"let g:battery#update_tabline = 1    " For tabline.
"let g:battery#update_statusline = 1 " For statusline.

"let g:neoformat_try_formatprg = 1
" Define some single Blade directives. This variable is used for highlighting only.
let g:blade_custom_directives = ['datetime', 'javascript', 'html', 'scss']

" Define pairs of Blade directives. This variable is used for highlighting and indentation.
let g:blade_custom_directives_pairs = {
      \   'markdown': 'endmarkdown',
      \   'cache': 'endcache',
      \ }

let g:indent_guides_start_level = 2

let g:user_emmet_install_global = 1

let g:ale_linters = { 
  \   'javascript' : ['eslint'],
  \ }
"let g:ale_fixers['javascript'] = ['eslint']
" Fix files automatically on save
let g:ale_fix_on_save = 1

"let g:vim_vue_plugin_load_full_syntax = 1
"let g:jsimport#reporting = 1

"Var AutoImport
"let g:jsimport#reporting = 1


"Kite 
"let g:kite_supported_languages = ['javascript']
"set completeopt+=menuone

"set completeopt+=preview
"let g:kite_previous_placeholder = '<C-H>'
"let g:kite_next_placeholder = '<C-L>``'



" javascript
let g:javascript_enable_domhtmlcss = 1


" typescript
"let g:yats_host_keyword = 1
let g:nvim_typescript#max_completion_detail=100



" svelte
let g:vim_svelte_plugin_load_full_syntax = 1


" vuejs
" vim vue
"let g:vue_disable_pre_processors=1
" vim vue plugin
"let g:vim_vue_plugin_load_full_syntax = 1 
"let g:vim_vue_plugin_use_scss = 1
"let g:vim_vue_plugin_has_init_indent = 1
"let g:vim_vue_plugin_highlight_vue_keyword = 1


"Example
"autocmd FileType vue inoremap <buffer><expr> : InsertColon()

"function! InsertColon()
""  let tag = GetVueTag()
""  return tag == 'template' ? ':' : ': '
"endfunction

let g:html_indent_script1 = "inc" 
let g:html_indent_style1 = "inc" 
let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_enable_vimfiler= 1
let g:AutoPairsFlyMode = 1
let g:AutoPairsShortcutBackInsert = '0'

let g:import_cost_show_gzipped = 1
let g:import_cost_always_open_split = 1
let g:import_cost_split_pos = 'right'
let g:import_cost_virtualtext = 0
let g:import_cost_virtualtext_prefix = " > "
let g:import_cost_silent = 1
