let current_compiler = 'dot'

if exists(':CompilerSet') != 2
    com -nargs=* CompilerSet setl <args>
endif

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

" Original_value:
"     setl efm=%EError:\ %f:%l:%m,%+Ccontext:\ %.%#,%WWarning:\ %m
"
"             from https://github.com/wannesm/wmgraphviz.vim

CompilerSet efm=Error:\ %f:\ %m\ %l\ %.%#
" from $VIMRUNTIME/compiler/dot.vim
CompilerSet mp=dot\ -T$*\ \"%:p\"\ -o\ \"%:p:r.$*\"
