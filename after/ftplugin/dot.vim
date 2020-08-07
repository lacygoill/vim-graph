" Commands {{{1

com -bar -buffer -range=% -nargs=+  -complete=custom,graph#cmd_complete Graph
    \ call graph#cmd(<q-args>, <line1>, <line2>)

" Mappings {{{1

nno <buffer><nowait><silent> <bar>c :<c-u>Graph -compile<cr>
xno <buffer><nowait><silent> <bar>c :Graph -compile<cr>

nno <buffer><nowait><silent> <bar>i :<c-u>Graph -interactive<cr>

nno <buffer><nowait><silent> <bar>s :<c-u>Graph -show<cr>
xno <buffer><nowait><silent> <bar>s :Graph -show<cr>

" Options {{{1

let b:mc_chain =<< trim END
    omni
    ulti
    keyn
END

setl cms=//\ %s

setl ofu=graph#omni_complete

compiler dot

" Teardown {{{1

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'exe')
    \ .. '| call graph#undo_ftplugin()'

