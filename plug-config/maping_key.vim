"=========================== All nmap ==========================

nmap <F3> :FloatermNew --height=0.6 --width=0.5 --wintype=float --name=floaterm1 --position=center <CR>
nmap <Leader>n :noh<CR>
map ; :Files<CR>
map "" :Line<CR>
map <F2> :NERDTreeToggle<CR>
vmap <leader>f  <Plug>(coc-format-selected)
nmap <Leader>Ea <Plug>(easymotion-s2)
nmap <Leader>s :w<CR>
nmap <Leader>q :q<CR>
nmap <leader>d <Plug>(ale_fix)
"nnoremap <Leader>n :<C-u>call gitblame#echo()<CR>
" ========================== End nmap========================
"
"
" ==========================All nnoremap=========================
nnoremap <leader>gm :Magit<CR>       
" Maping for React
"nnoremap <Leader>if <Plug>(JsFileImport)

"nnoremap <Leader>iF <Plug>(JsFileImportList)

"nnoremap <Leader>ig <Plug>(JsGotoDefinition)

"nnoremap <Leader>iG <Plug>(JsGotoDefinition)

"nnoremap <Leader>ip <Plug>(PromptJsFileImport)

"nnoremap <Leader>is <Plug>(SortJsFileImport)

"nnoremap <Leader>ic <Plug>(JsFixImport)

"" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Gcommit<CR>
noremap <Leader>gsh :Gpush<CR>
noremap <Leader>gll :Gpull<CR>
noremap <Leader>gs :Gstatus<CR>
noremap <Leader>gb :Gblame<CR>
"noremap <Leader>gd :Gvdiff<CR>
"noremap <Leader>gr :Gremove<CR>
"" Open current line on GitHub
nnoremap <Leader>o :.Gbrowse<CR>
nnoremap <leader>so :OpenSession<Space>
nnoremap <leader>ss :SaveSession<Space>
nnoremap <leader>sd :DeleteSession<CR>
nnoremap <leader>sc :CloseSession<CR>
"" Tabs
nnoremap <silent> <S-t> :tabnew<CR>
"" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>
"" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>
"" Opens a tab edit command with the path of the currently edited file filled
noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

"nnoremap <silent> <space>qq  :exe 'CocList -I --normal --input='.expand('<cword>').' words'<CR>

" Keymapping for grep word under cursor with interactive mode
"nnoremap <silent> <Leader>cf :exe 'CocList -I --input='.expand('<cword>').' grep'<CR>

vnoremap <leader>g :<C-u>call <SID>GrepFromSelected(visualmode())<CR>
nnoremap <leader>g :<C-u>set operatorfunc=<SID>GrepFromSelected<CR>g@
" ======================End nnoremap==========================================================

au TermEnter * setlocal scrolloff=0
au TermLeave * setlocal scrolloff=3


" ===============================Functions====================================================
" grep word under cursor
command! -nargs=+ -complete=custom,s:GrepArgs Rg exe 'CocList grep '.<q-args>

function! s:GrepArgs(...)
  let list = ['-S', '-smartcase', '-i', '-ignorecase', '-w', '-word',
        \ '-e', '-regex', '-u', '-skip-vcs-ignores', '-t', '-extension']
  return join(list, "\n")
endfunction


function! s:GrepFromSelected(type)
  let saved_unnamed_register = @@
  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  else
    return
  endif
  let word = substitute(@@, '\n$', '', 'g')
  let word = escape(word, '| ')
  let @@ = saved_unnamed_register
  execute 'CocList grep '.word
endfunction


nnoremap <leader>sv :source $MYVIMRC<CR>

vmap <S-Tab> <gv
vmap <Tab> >gv

" >> Telescope bindings
nnoremap <Leader>pp :lua require'telescope.builtin'.builtin{}<CR>

nnoremap <Leader>pP :lua require'telescope.builtin'.planes{}<CR>

" most recentuly used files
nnoremap <Leader>m :lua require'telescope.builtin'.oldfiles{}<CR>

" find buffer
nnoremap " :lua require'telescope.builtin'.buffers{}<CR>

" find in current buffer
nnoremap <Leader>/ :lua require'telescope.builtin'.current_buffer_fuzzy_find{}<CR>

" bookmarks
nnoremap <Leader>' :lua require'telescope.builtin'.marks{}<CR>

" git files
nnoremap <Leader>f :lua require'telescope.builtin'.git_files{}<CR>

" all files
nnoremap <Leader>bfs :lua require'telescope.builtin'.find_files{}<CR>

" ripgrep like grep through dir
nnoremap <Leader>rg :lua require'telescope.builtin'.live_grep{}<CR>

" pick color scheme
nnoremap <Leader>cs :lua require'telescope.builtin'.colorscheme{}<CR>

nnoremap <Leader>cc :lua require'telescope.builtin'.previewers.vim_buffer_cat.new<CR>
autocmd User TelescopePreviewerLoaded setlocal wrap

" Find files using Telescope command-line sugar.
" nnoremap <leader>ff <cmd>Telescope find_files<cr>
" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
" nnoremap <leader>fb <cmd>Telescope buffers<cr>
" nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Using Lua functions
" nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files({previewer=true})<cr>
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep({previewer= true}, { prompt_prefix=🔍 })<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers({previewer =true)<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>


" >> setup nerdcomment key bindings
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1

xnoremap <Leader>ci :call NERDComment('n', 'toggle')<CR>
nnoremap <Leader>ci :call NERDComment('n', 'toggle')<CR>


" >> Lsp key bindings
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <C-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K     <cmd>Lspsaga hover_doc<CR>
nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> <C-p> <cmd>Lspsaga diagnostic_jump_prev<CR>
nnoremap <silent> <C-n> <cmd>Lspsaga diagnostic_jump_next<CR>
nnoremap <silent> gf    <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent> gn    <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> ga    <cmd>Lspsaga code_action<CR>
xnoremap <silent> ga    <cmd>Lspsaga range_code_action<CR>
nnoremap <silent> gs    <cmd>Lspsaga signature_help<CR>

lua <<EOF
require("lsp")
require("treesitter")
require("statusbar")
EOF

