if exists('g:loaded_graph')
    finish
endif
let g:loaded_graph = 1

nno <unique> ge <cmd>call graph#edit_diagram()<cr>
xno <unique> ge <c-\><c-n><cmd>call graph#create_diagram()<cr>
