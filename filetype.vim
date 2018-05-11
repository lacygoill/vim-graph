if exists('did_load_filetypes')
    finish
endif

augroup filetypedetect
    au! BufRead,BufNewFile  *.{dot,gv}  set filetype=dot
augroup END
