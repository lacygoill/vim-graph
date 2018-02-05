fun! s:detect_dot()
    if getline(1) ==# 'digraph'
        set filetype=dot
    endif
endfun

au BufRead,BufNewFile  *.{dot,gv}  set filetype=dot
au BufRead,BufNewFile  *           call s:detect_dot()

