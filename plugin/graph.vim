if exists('g:loaded_graph')
    finish
endif
let g:loaded_graph = 1

nno  <silent><unique>  ge  :<c-u>call graph#edit_diagram()<cr>
