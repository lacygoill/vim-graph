" Commands {{{1

com! -buffer -nargs=1   -complete=custom,graph#cmd_complete  GraphCompile  call graph#compile(<q-args>)
com! -buffer -nargs=0  GraphInteractive  call graph#interactive()
com! -buffer -nargs=0  GraphShow         call graph#show()

cnorea  <buffer><expr>  graphcompile  getcmdtype() ==# ':' && getcmdline() ==# 'graphcompile'
\                                     ?    'GraphCompile'
\                                     :    'graphcompile'

cnorea  <buffer><expr>  graphinteractive  getcmdtype() ==# ':' && getcmdline() ==# 'graphinteractive'
\                                         ?    'GraphInteractive'
\                                         :    'graphinteractive'

cnorea  <buffer><expr>  graphshow  getcmdtype() ==# ':' && getcmdline() ==# 'graphshow'
\                                  ?    'GraphShow'
\                                  :    'graphshow'

" Mappings {{{1

nno  <buffer><nowait><silent>  <bslash>c  :<c-u>GraphCompile<cr>
nno  <buffer><nowait><silent>  <bslash>s  :<c-u>GraphShow<cr>
nno  <buffer><nowait><silent>  <bslash>i  :<c-u>GraphInteractive<cr>

" Options {{{1

let b:mc_chain = [
\                  'omni',
\                  'ulti',
\                  'keyp',
\                ]

setl cms=//%s

setl efm=%EError:\ %f:%l:%m,%+Ccontext:\ %.%#,%WWarning:\ %m

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
\                        | exe 'cuna   <buffer> graphcompile'
\                        | exe 'cuna   <buffer> graphinteractive'
\                        | exe 'cuna   <buffer> graphshow'
\                        | delc GraphCompile
\                        | delc GraphInteractive
\                        | delc GraphShow
\                      "

