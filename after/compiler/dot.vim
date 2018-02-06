let current_compiler = 'dot'

if exists(':CompilerSet') != 2
    com -nargs=* CompilerSet setl <args>
endif

" CompilerSet efm=
" CompilerSet mp=
