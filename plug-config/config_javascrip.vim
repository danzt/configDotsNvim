autocmd BufWritePre *.js Neoformat
autocmd BufWritePre,TextChanged,InsertLeave *.js Neoformat
augroup NeoformatAutoFormat
    autocmd!
    autocmd FileType javascript, javascript.jsx setlocal formatprg=prettier\
                                             \--stdin\
                                             \--print-width\ 80\
                                             \--single-quote\
                                             \--trailing-comma\ es5
    autocmd BufWritePre *.js, *.jsx Neoformat
augroup END

"use <<c-space>> autocomplete para javascript
if &filetype == 'javascript'
	inoremap <c-space> <C-x><C-u>
else
	inoremap <silent><expr> <c-space> coc#refresh()
endif
" for html files, 2 spaces
autocmd Filetype html setlocal ts=2 sw=2 expandtab

au BufRead *.html set filetype=htmlm4

autocmd FileType html,css EmmetInstall


