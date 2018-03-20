let current_compiler = 'dot'

if exists(':CompilerSet') != 2
    com -nargs=* CompilerSet setl <args>
endif

" adapted from $VIMRUNTIME/compiler/dot.vim
CompilerSet mp=dot\ -T$*\ '%:p:S'\ -o\ '%:p:r:S.$*'
"                              │
"                              └ escape characters special to the shell

" Original_value:
"     setl efm=%EError:\ %f:%l:%m,%+Ccontext:\ %.%#,%WWarning:\ %m
"
"             from https://github.com/wannesm/wmgraphviz.vim/blob/eff46932ef8324ab605c18619e94f6b631d805e2/ftplugin/dot.vim#L560

CompilerSet efm=%+EError:\ %f:\ %.%#\ %l\ %.%#
"               └─┤             └──┤{{{
"                 │                └ stands for the regex .*
"                 │
"                 └ start of a multi-line error message
"
"                   It  works  even though,  atm,  our  error messages  are  not
"                   multi-line, which  seems to indicate  that %E can work  on a
"                   single line error message too.
"
"                   The `+` includes the whole matching line in the %m error string.
"                   It works even  though we don't use any `%m`,  which seems to
"                   indicate that you don't need a `%m` in a format using `%+`.
"}}}
" This value is useful for an error like this:
"
"         Error: /tmp/file.dot: syntax error in line 40 near '['
