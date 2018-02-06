" Commands {{{1

com! -buffer -nargs=+  -complete=custom,graph#cmd_complete  Graph  call graph#cmd(<q-args>)

cnorea  <buffer><expr>  graph  getcmdtype() ==# ':' && getcmdline() ==# 'graph'
\                              ?    'Graph'
\                              :    'graph'

" Mappings {{{1

nno  <buffer><nowait><silent>  <bslash>c  :<c-u>Graph -compile<cr>
nno  <buffer><nowait><silent>  <bslash>i  :<c-u>Graph -interactive<cr>
nno  <buffer><nowait><silent>  <bslash>s  :<c-u>Graph -show<cr>

" Options {{{1

let b:mc_chain = [
\    'omni',
\    'ulti',
\    'keyp',
\ ]

setl cms=//%s

" FIXME:
" The current value fails to parse the current error messages looking like this:
"
"         |  | Error: /tmp/file.dot: syntax error in line 40 near '['

" This somewhat works:
"
"         let &l:efm = 'Error: %f: %m %l %.%#'
"
" But we miss the end of the error message.
" How to parse an error message, where the message contains the line address?

let &l:efm = 'Error: %f: %m %l %.%#'
" Original_value:
"     setl efm=%EError:\ %f:%l:%m,%+Ccontext:\ %.%#,%WWarning:\ %m

let &l:ofu = 'graph#omni_complete'

" Teardown {{{1

let b:undo_ftplugin =         get(b:, 'undo_ftplugin', '')
\                     .(empty(get(b:, 'undo_ftplugin', '')) ? '' : '|')
\                     ."
\                          setl cms< efm< ofu<
\                        | unlet! b:mc_chain
\                        | exe 'nunmap <buffer> <bslash>c'
\                        | exe 'nunmap <buffer> <bslash>i'
\                        | exe 'nunmap <buffer> <bslash>s'
\                        | exe 'cuna   <buffer> graph'
\                        | delc Graph
\                      "

