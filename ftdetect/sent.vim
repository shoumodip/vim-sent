autocmd BufNewFile,BufRead *.sent set filetype=sent
autocmd BufNewFile,BufRead * if getline(1) =~? '^#\s*sent$' | set filetype=sent | endif
