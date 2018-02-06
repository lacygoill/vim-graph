" Commands {{{1

com! -buffer -range=% -nargs=+  -complete=custom,graph#cmd_complete  Graph
\     call graph#cmd(<q-args>, <line1>, <line2>)

cnorea  <buffer><expr>  graph  getcmdtype() ==# ':' && getcmdline() ==# 'graph'
\                              ?    'Graph'
\                              :    'graph'

" Mappings {{{1

nno  <buffer><nowait><silent>  <bslash>c  :<c-u>Graph -compile<cr>
xno  <buffer><nowait><silent>  <bslash>c  :Graph -compile<cr>

nno  <buffer><nowait><silent>  <bslash>i  :<c-u>Graph -interactive<cr>

nno  <buffer><nowait><silent>  <bslash>s  :<c-u>Graph -show<cr>
xno  <buffer><nowait><silent>  <bslash>s  :Graph -show<cr>

" Options {{{1

let b:mc_chain = [
\    'omni',
\    'ulti',
\    'keyp',
\ ]

setl cms=//%s

setl ofu=graph#omni_complete

compiler dot

" Teardown {{{1

let b:undo_ftplugin =         get(b:, 'undo_ftplugin', '')
\                     .(empty(get(b:, 'undo_ftplugin', '')) ? '' : '|')
\                     ."
\                          setl cms< efm< mp< ofu<
\                        | unlet! b:mc_chain
\                        | exe 'nunmap <buffer> <bslash>c'
\                        | exe 'xunmap <buffer> <bslash>c'
\                        | exe 'nunmap <buffer> <bslash>i'
\                        | exe 'nunmap <buffer> <bslash>s'
\                        | exe 'xunmap <buffer> <bslash>s'
\                        | exe 'cuna   <buffer> graph'
\                        | delc Graph
\                      "

