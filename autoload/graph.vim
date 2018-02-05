if exists('g:autoloaded_graph')
    finish
endif
let g:autoloaded_graph = 1

" Variables {{{1

let s:completion_type = ''

" [E] = Edge
" [G] = Graph
" [N] = Node
let s:attrs = [
\    {'word': 'arrowhead=',     'menu': 'Style of arrowhead at head end [E]'},
\    {'word': 'arrowsize=',     'menu': 'Scaling factor for arrowheads [E]'},
\    {'word': 'arrowtail=',     'menu': 'Style of arrowhead at tail end [E]'},
\    {'word': 'bgcolor=',       'menu': 'Background color [G]'},
\    {'word': 'color=',         'menu': 'Node shape/edge/cluster color [E,G,N]'},
\    {'word': 'comment=',       'menu': 'Any string [E,G,N]'},
\    {'word': 'compound=',      'menu': 'Allow edges between clusters [G]'},
\    {'word': 'concentrate=',   'menu': 'Enables edge concentrators [G]'},
\    {'word': 'constraints=',   'menu': 'Use edge to affect node ranking [E]'},
\    {'word': 'decorate=',      'menu': 'If set, line between label and edge [E]'},
\    {'word': 'dir=',           'menu': 'Direction of edge [E]'},
\    {'word': 'distortion=',    'menu': 'Node distortion [N]'},
\    {'word': 'fillcolor=',     'menu': 'Node/cluster fill color [G,N]'},
\    {'word': 'fixedsize=',     'menu': 'Label text has no effect on node size [N]'},
\    {'word': 'fontcolor=',     'menu': 'Font face color [E,G,N]'},
\    {'word': 'fontname=',      'menu': 'Font family [E,G,N]'},
\    {'word': 'fontsize=',      'menu': 'Point size of label [E,G,N]'},
\    {'word': 'group=',         'menu': 'Name of node group [N]'},
\    {'word': 'headlabel=',     'menu': 'Label placed near head of edge [E]'},
\    {'word': 'headport=',      'menu': 'Where on the node to attach head of edge [E]'},
\    {'word': 'height=',        'menu': 'Height in inches [N]'},
\    {'word': 'label=',         'menu': 'Any string [E,N]'},
\    {'word': 'labelangle=',    'menu': 'Ange in degrees [E]'},
\    {'word': 'labeldistance=', 'menu': 'Scaling factor for distance for head or tail label [E]'},
\    {'word': 'labelfontcolor=','menu': 'Type face color for head and tail labels [E]'},
\    {'word': 'labelfontname=', 'menu': 'Font family for head and tail labels [E]'},
\    {'word': 'labelfontsize=', 'menu': 'Point size for head and tail labels [E]'},
\    {'word': 'labeljust=',     'menu': 'Label justficiation [G]'},
\    {'word': 'labelloc=',      'menu': 'Label vertical justficiation [G]'},
\    {'word': 'layer=',         'menu': 'Overlay range [E,N]'},
\    {'word': 'lhead=',         'menu': '[E]'},
\    {'word': 'ltail=',         'menu': '[E]'},
\    {'word': 'minlen=',        'menu': '[E]'},
\    {'word': 'nodesep=',       'menu': 'Separation between nodes, in inches [G]'},
\    {'word': 'orientation=',   'menu': 'Node rotation angle [N]'},
\    {'word': 'peripheries=',   'menu': 'Number of node boundaries [N]'},
\    {'word': 'rank=',          'menu': '[G]'},
\    {'word': 'rankdir=',       'menu': '[G]'},
\    {'word': 'ranksep=',       'menu': 'Separation between ranks, in inches [G]'},
\    {'word': 'ratio=',         'menu': 'Aspect ratio [G]'},
\    {'word': 'regular=',       'menu': 'Force polygon to be regular [N]'},
\    {'word': 'rotate=',        'menu': 'If 90, set orientation to landscape [G]'},
\    {'word': 'samehead=',      'menu': '[E]'},
\    {'word': 'sametail=',      'menu': '[E]'},
\    {'word': 'shape=',         'menu': 'Node shape [N]'},
\    {'word': 'shapefile=',     'menu': 'External custom shape file [N]'},
\    {'word': 'sides=',         'menu': 'Number of sides for shape=polygon [N]'},
\    {'word': 'skew=',          'menu': 'Skewing node for for shape=polygon [N]'},
\    {'word': 'style=',         'menu': 'Graphics options [E,N]'},
\    {'word': 'taillabel=',     'menu': 'Label placed near tail of edge [E]'},
\    {'word': 'tailport=',      'menu': 'Where on the node to attach tail of edge [E]'},
\    {'word': 'weight=',        'menu': 'Integer cost of stretching an edge [E]'},
\    {'word': 'width=',         'menu': 'width in inches [N]'},
\ ]

let s:shapes = [
\    {'word': 'box'},
\    {'word': 'circle'},
\    {'word': 'diamond'},
\    {'word': 'doublecircle'},
\    {'word': 'doubleoctagon'},
\    {'word': 'egg'},
\    {'word': 'ellipse'},
\    {'word': 'hexagon'},
\    {'word': 'house'},
\    {'word': 'invhouse'},
\    {'word': 'invtrapezium'},
\    {'word': 'invtriangle'},
\    {'word': 'octagon'},
\    {'word': 'plaintext'},
\    {'word': 'parallelogram'},
\    {'word': 'point'},
\    {'word': 'polygon'},
\    {'word': 'record'},
\    {'word': 'trapezium'},
\    {'word': 'triangle'},
\    {'word': 'tripleoctagon'},
\    {'word': 'Mcircle'},
\    {'word': 'Mdiamond'},
\    {'word': 'Mrecord'},
\    {'word': 'Msquare'},
\ ]

let s:arrowheads = [
\    {'word': 'normal'},
\    {'word': 'dot'},
\    {'word': 'odot'},
\    {'word': 'inv'},
\    {'word': 'invdot'},
\    {'word': 'invodot'},
\    {'word': 'none'},
\ ]

" More colornames are available but make the menu too long.
let s:colors = [
\       {'word': '#000000'},
\       {'word': '0.0 0.0 0.0'},
\       {'word': 'beige'},
\       {'word': 'black'},
\       {'word': 'blue'},
\       {'word': 'brown'},
\       {'word': 'cyan'},
\       {'word': 'gray'},
\       {'word': 'gray[0-100]'},
\       {'word': 'green'},
\       {'word': 'magenta'},
\       {'word': 'orange'},
\       {'word': 'orchid'},
\       {'word': 'red'},
\       {'word': 'violet'},
\       {'word': 'white'},
\       {'word': 'yellow'},
\ ]

let s:fonts = [
\    {'abbr': 'Courier'          , 'word': '"Courier"'},
\    {'abbr': 'Courier-Bold'     , 'word': '"Courier-Bold"'},
\    {'abbr': 'Courier-Oblique'  , 'word': '"Courier-Oblique"'},
\    {'abbr': 'Helvetica'        , 'word': '"Helvetica"'},
\    {'abbr': 'Helvetica-Bold'   , 'word': '"Helvetica-Bold"'},
\    {'abbr': 'Helvetica-Narrow' , 'word': '"Helvetica-Narrow"'},
\    {'abbr': 'Helvetica-Oblique', 'word': '"Helvetica-Oblique"'},
\    {'abbr': 'Symbol'           , 'word': '"Symbol"'},
\    {'abbr': 'Times-Bold'       , 'word': '"Times-Bold"'},
\    {'abbr': 'Times-BoldItalic' , 'word': '"Times-BoldItalic"'},
\    {'abbr': 'Times-Italic'     , 'word': '"Times-Italic"'},
\    {'abbr': 'Times-Roman'      , 'word': '"Times-Roman"'},
\ ]

let s:style = [
\    {'word': 'diagonals', 'menu': '[N]'},
\    {'word': 'filled',    'menu': '[N]'},
\    {'word': 'rounded',   'menu': '[N]'},
\    {'word': 'striped',   'menu': '[N]'},
\    {'word': 'wedged',    'menu': '[N]'},
\    {'word': 'tapered',   'menu': '[E]'},
\    {'word': 'bold',      'menu': '[E,N]'},
\    {'word': 'dashed',    'menu': '[E,N]'},
\    {'word': 'dotted',    'menu': '[E,N]'},
\    {'word': 'invis',     'menu': '[E,N]'},
\    {'word': 'solid',     'menu': '[E,N]'},
\ ]

let s:dir = [
\    {'word': 'forward'},
\    {'word': 'back'},
\    {'word': 'both'},
\    {'word': 'none'},
\ ]

let s:port = [
\    {'word': '_',   'menu': 'appropriate side or center (default)'},
\    {'word': 'c',   'menu': 'center'},
\    {'word': 'e'},
\    {'word': 'n'},
\    {'word': 'ne'},
\    {'word': 'nw'},
\    {'word': 's'},
\    {'word': 'se'},
\    {'word': 'sw'},
\    {'word': 'w'},
\ ]

let s:rank = [
\    {'word': 'same'},
\    {'word': 'min'},
\    {'word': 'max'},
\    {'word': 'source'},
\    {'word': 'sink'},
\ ]

let s:rankdir = [
\    {'word': 'BT'},
\    {'word': 'LR'},
\    {'word': 'RL'},
\    {'word': 'TB'},
\ ]

let s:just = [
\    {'word': 'centered'},
\    {'word': 'l'},
\    {'word': 'r'},
\ ]

let s:loc = [
\    {'word': 'b', 'menu': 'bottom'},
\    {'word': 'c', 'menu': 'center'},
\    {'word': 't', 'menu': 'top'},
\ ]

let s:boolean = [
\    {'word': 'true'},
\    {'word': 'false'},
\ ]

fu! graph#cmd(action, ...) abort "{{{1
    if a:action =~# '-compile'
        call s:compile(a:0 ? a:1 : 'dot')
    else
        let funcname = matchstr(a:action, '-\zs\S\+')
        if empty(funcname) || !exists('*s:'.funcname)
            return
        else
            call s:{funcname}()
        endif
    endif
endfu

fu! graph#cmd_complete(arglead, cmdline, _p) abort "{{{1
    let options = [
    \               '-compile ',
    \               '-interactive ',
    \               '-show ',
    \             ]
    if a:arglead[0] ==# '-' || empty(a:arglead) && a:cmdline !~# '-compile\s\+\w*$'
        return join(options, "\n")
    else
        return join(['circo', 'dot2text', 'fdp', 'neato', 'sfdp', 'twopi'], "\n")
    endif
endfu

fu! graph#omni_complete(findstart, base) abort "{{{1
    " pas con!
    "     echomsg 'findstart='.a:findstart.', base='.a:base
    if a:findstart
        let line = getline('.')
        let pos = col('.') - 1
        while pos > 0 && line[pos - 1] !~ '=\|,\|\[\|\s'
            let pos -= 1
        endwhile
        let withspacepos = pos
        if line[withspacepos - 1] =~ '\s'
            while withspacepos > 0 && line[withspacepos - 1] !~ '=\|,\|\['
                let withspacepos -= 1
            endwhile
        endif

        if line[withspacepos - 1] == '='
            " label=...?
            let labelpos = withspacepos - 1
            " ignore spaces
            while labelpos > 0 && line[labelpos - 1] =~ '\s'
                let labelpos -= 1
                let withspacepos -= 1
            endwhile
            while labelpos > 0 && line[labelpos - 1] =~ '[a-z]'
                let labelpos -= 1
            endwhile
            let labelstr=strpart(line, labelpos, withspacepos - 1 - labelpos)

            let s:completion_type = labelstr == 'shape'
            \?                          'shapes'
            \:                      labelstr =~ 'fontname'
            \?                          'fonts'
            \:                      labelstr =~ 'color'
            \?                          'colors'
            \:                      labelstr == 'arrowhead'
            \?                          'arrowhead'
            \:                      labelstr == 'rank'
            \?                          'rank'
            \:                      labelstr == 'headport' || labelstr == 'tailport'
            \?                          'port'
            \:                      labelstr == 'rankdir'
            \?                          'rankdir'
            \:                      labelstr == 'style'
            \?                          'style'
            \:                      labelstr == 'labeljust'
            \?                          'just'
            \:                      index([
            \                               'center',
            \                               'compound',
            \                               'concentrate',
            \                               'constraint',
            \                               'fixedsize',
            \                               'labelfloat',
            \                               'regular',
            \                             ],
            \                              labelstr) >= 0
            \?                          'boolean'
            \:                      labelstr == 'labelloc'
            \?                          'loc'
            \:                          ''

        elseif line[withspacepos - 1] =~ ',\|\['
            " attr
            let attrstr=line[0:withspacepos - 1]
            " skip spaces
            while line[withspacepos] =~ '\s'
                let withspacepos += 1
            endwhile

            let s:completion_type = attrstr =~ '^\s*node'
            \?                          'attrnode'
            \:                      attrstr =~ '^\s*edge'
            \?                          'attredge'
            \:                      attrstr =~ '\( -> \)\|\( -- \)'
            \?                          'attredge'
            \:                      attrstr =~ '^\s*graph'
            \?                          'attrgraph'
            \:                          'attrnode'
        else
            let s:completion_type = ''
        endif

        return pos
    else

        if s:completion_type =~# '^attr'
            return filter(copy(s:attrs), {i,v ->     stridx(v.word, a:base) == 0
            \                                     && v.menu =~ '\[.*'.toupper(s:completion_type[4]).'.*\]' })
        elseif index([
            \          'arrowhead',
            \          'boolean',
            \          'colors',
            \          'fonts',
            \          'just',
            \          'loc',
            \          'port',
            \          'rank',
            \          'rankdir',
            \          'shapes',
            \          'style',
            \], s:completion_type) == -1
            return []
        endif

        return filter(copy(s:{s:completion_type}), {i,v -> stridx(v.word, a:base) == 0 })
    endif
endfu

fu! s:compile(cmd) abort "{{{1
    if !executable(a:cmd)
        echoerr 'The '.string(a:cmd).' executable was not found.'
        return
    endif

    let s:logfile = s:graph_log_file()
    sil exe printf('!(%s -Tpdf %s -o %s 2>&1) | tee %s',
    \          a:cmd,
    \          shellescape(expand('%:p'), 1),
    \          shellescape(s:graph_output_file('pdf'), 1),
    \          shellescape(s:logfile, 1)
    \)
    redraw!

    if getfsize(s:logfile)
        exe 'cfile '.escape(s:logfile, ' \"!?''')
    endif
    call delete(s:logfile)
endfu

fu! s:graph_log_file() abort "{{{1
    return tempname().'.log'
endfu

fu! s:graph_output_file(output) abort "{{{1
    return expand('%:p:r').'.'.a:output
endfu

fu! s:interactive() abort "{{{1
    " Interactive viewing.  "dot -Txlib  <file.gv>" uses inotify  to immediately
    " redraw image when the input file is changed.

    if !executable('dot')
        echoerr 'The '.string('dot').' executable was not found.'
        return
    endif

    sil exe '!dot -Txlib '.shellescape(expand('%:p')).' &'
    redraw!
endfu

fu! s:show() abort "{{{1
    if !filereadable(s:graph_output_file('pdf'))
        call s:graph_compile('dot')
    endif

    if !executable('xdg-open')
        echoerr 'Viewer program not found:  xdg-open'
        return
    endif
    call system('xdg-open '.shellescape(s:graph_output_file('pdf')))
endfu
