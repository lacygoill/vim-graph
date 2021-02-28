if exists('g:autoloaded_graph')
    finish
endif
let g:autoloaded_graph = v:true

" FIXME:
" There are 2 new kinds of attributes (S and C).
" We don't take them into account in the omni completion function.

" TODO:
" Implement  a command  to convert  a  pdf to  a  png/jpeg.  Only  format to  be
" accepted on a forum.
"
" Study this command:
"
"     $ convert -verbose       \
"               -density 150   \
"               -trim          \
"               input.pdf      \
"                              \
"               -quality 100   \
"               -flatten       \
"               -sharpen 0x1.0 \
"               output.jpg
"
" Source:
" https://stackoverflow.com/a/6605085/9110115
"
" Or maybe a simpler and faster tool would be `pdftoppm`:
"
"     $ pdftoppm input.pdf output -png
"
" https://askubuntu.com/a/50180

" Variables {{{1

" This is  the variable you need  to change, if you  want to view your  graph in
" another format.
const s:FORMAT = 'pdf'

const s:VIEWERS = #{
    \ pdf: 'zathura',
    \ png: 'feh',
    \ }

const s:VIEWER = get(s:VIEWERS, s:FORMAT, 'xdg-open')

let s:completion_type = ''

" arrowhead {{{2

let s:ARROWHEAD = [
    \ #{word: 'box'},
    \ #{word: 'crow'},
    \ #{word: 'curve'},
    \ #{word: 'icurve'},
    \ #{word: 'diamond'},
    \ #{word: 'dot'},
    \ #{word: 'inv'},
    \ #{word: 'none'},
    \ #{word: 'normal'},
    \ #{word: 'tee'},
    \ #{word: 'vee'},
    \ ]

" attribute {{{2

" [E] = Edge
" [N] = Node
" [G] = root Graph
" [S] = Subgraph
" [C] = Cluster subgraph

" We've stopped at layer.

" Source:
" https://graphviz.gitlab.io/_pages/doc/info/attrs.html
" https://graphviz.gitlab.io/documentation

let s:ATTRS = [
    \ #{word: 'Damping=',            menu: 'Factor damping force motions [G]'},
    \ #{word: 'K=',                  menu: 'Spring constant used in virtual physical model [G,C]'},
    \ #{word: 'URL=',                menu: 'Hyperlinks incorporated into device-dependent output [E,N,G,C]'},
    \ #{word: '_background=',        menu: 'A string in the xdot format specifying an arbitrary background [G]'},
    \ #{word: 'area=',               menu: 'Preferred area for a node or empty cluster when laid out by patchwork [N,C]'},
    \ #{word: 'arrowhead=',          menu: 'Style of arrowhead on the head node of an edge [E]'},
    \ #{word: 'arrowsize=',          menu: 'Multiplicative scale factor for arrowheads [E]'},
    \ #{word: 'arrowtail=',          menu: 'Style of arrowhead on the tail node of an edge [E]'},
    \ #{word: 'bb=',                 menu: 'Bounding box of drawing in points [G]'},
    \ #{word: 'bgcolor=',            menu: 'Background color [G,C]'},
    \ #{word: 'center=',             menu: 'If true, the drawing is centered in the output canvas [G]'},
    \ #{word: 'charset=',            menu: 'Character encoding used when interpreting string input as a text label [G]'},
    \ #{word: 'clusterrank=',        menu: 'Mode used for handling clusters [G]'},
    \ #{word: 'color=',              menu: 'Basic drawing color for graphics, not text [E,N,C]'},
    \ #{word: 'colorscheme=',        menu: 'Color scheme namespace [E,N,C,G]'},
    \ #{word: 'comment=',            menu: 'Comments are inserted into output [E,N,G]'},
    \ #{word: 'compound=',           menu: 'If true, allow edges between clusters [G]'},
    \ #{word: 'concentrate=',        menu: 'If true, use edge concentrators [G]'},
    \ #{word: 'constraint=',         menu: 'If false, the edge is not used in ranking the nodes [E]'},
    \ #{word: 'decorate=',           menu: 'If true, attach edge label to edge by a 2-segment polyline,… [E]'},
    \ #{word: 'defaultdist=',        menu: 'distance between nodes in separate connected components [G]'},
    \ #{word: 'dim=',                menu: 'number of dimensions used for the layout [G]'},
    \ #{word: 'dimen=',              menu: 'number of dimensions used for rendering [G]'},
    \ #{word: 'dir=',                menu: 'Set edge type for drawing arrowheads [E]'},
    \ #{word: 'diredgeconstraints=', menu: '… [G]'},
    \ #{word: 'distortion=',         menu: 'Distortion factor for shape=polygon [N]'},
    \ #{word: 'dpi=',                menu: 'Expected number of pixels per inch on a display device [G]'},
    \ #{word: 'edgeURL=',            menu: 'Link used for the non-label parts of an edge [E]'},
    \ #{word: 'edgehref=',           menu: 'Synonym for edgeURL [E]'},
    \ #{word: 'edgetarget=',         menu: '… [E]'},
    \ #{word: 'edgetooltip=',        menu: 'Tooltip annotation attached to the non-label part of an edge [E]'},
    \ #{word: 'epsilon=',            menu: 'Terminating condition [G]'},
    \ #{word: 'esep=',               menu: 'Margin used around polygons for purposes of spline edge routing [G]'},
    \ #{word: 'fillcolor=',          menu: 'Color used to fill the background of a node or cluster assuming style=filled, or a filled arrowhead [N,E,C]'},
    \ #{word: 'fixedsize=',          menu: 'Label text has no effect on node size [N]'},
    \ #{word: 'fontcolor=',          menu: 'Color used for text [E,N,G,C]'},
    \ #{word: 'fontname=',           menu: 'Font used for text [E,N,G,C]'},
    \ #{word: 'fontnames=',          menu: 'Allows user control of how basic fontnames are represented in SVG output [G]'},
    \ #{word: 'fontpath=',           menu: '… [G]'},
    \ #{word: 'fontsize=',           menu: 'Font size, in points, used for text [E,N,G,C]'},
    \ #{word: 'group=',              menu: 'Name of node group [N]'},
    \ #{word: 'headURL=',            menu: 'If headURL is defined, it is output as part of the head label of the edge [E]'},
    \ #{word: 'head_lp=',            menu: 'Position of an edge''s head label, in points [E]'},
    \ #{word: 'headclip=',           menu: '… [E]'},
    \ #{word: 'headhref=',           menu: 'Synonm for headURL [E]'},
    \ #{word: 'headlabel=',          menu: 'Text label to be placed near head of edge [E]'},
    \ #{word: 'headport=',           menu: 'Where on the head node to attach the head of the edge [E]'},
    \ #{word: 'height=',             menu: 'Height of node, in inches [N]'},
    \ #{word: 'href=',               menu: 'Synonm for URL [G,C,N,E]'},
    \ #{word: 'id=',                 menu: '… [G,C,N,E]'},
    \ #{word: 'image=',              menu: 'Gives the name of a file containing an image to be displayed inside a node [N]'},
    \ #{word: 'imagepath=',          menu: '… [G]'},
    \ #{word: 'imagepos=',           menu: 'Attribute controlling how an image is positioned within its containing node [N]'},
    \ #{word: 'imagescale=',         menu: 'controlling how an image fills its containing node [N]'},
    \ #{word: 'inputscale=',         menu: 'controlling how an image fills its containing node [G]'},
    \ #{word: 'label=',              menu: 'Text label attached to objects [E,N,G,C]'},
    \ #{word: 'labelURL=',           menu: 'Link used for the label of an edge [E]'},
    \ #{word: 'label_scheme=',       menu: '… [G]'},
    \ #{word: 'labelangle=',         menu: 'Ange in degrees [E]'},
    \ #{word: 'labeldistance=',      menu: '… [E]'},
    \ #{word: 'labelfloat=',         menu: 'Allows edge labels to be less constrained in position [E]'},
    \ #{word: 'labelfontcolor=',     menu: 'Color used for headlabel and taillabel [E]'},
    \ #{word: 'labelfontname=',      menu: 'Font used for headlabel and taillabel [E]'},
    \ #{word: 'labelfontsize=',      menu: 'Font size, in points, used for headlabel and taillabel [E]'},
    \ #{word: 'labelhref=',          menu: 'Synonym for labelURL [E]'},
    \ #{word: 'labeljust=',          menu: 'Justification for cluster labels [G,C]'},
    \ #{word: 'labelloc=',           menu: 'Vertical placement of labels for nodes, root graphs and clusters [N,G,C]'},
    \ #{word: 'labeltarget=',        menu: '… [E]'},
    \ #{word: 'labeltooltip=',       menu: 'Tooltip annotation attached to label of an edge [E]'},
    \ #{word: 'landscape=',          menu: 'If true, the graph is rendered in landscape mode [G]'},
    \ #{word: 'layer=',              menu: 'layers in which the node, edge or cluster is present [E,N,C]'},
    \ #{word: 'lhead=',              menu: '[E]'},
    \ #{word: 'ltail=',              menu: '[E]'},
    \ #{word: 'minlen=',             menu: '[E]'},
    \ #{word: 'nodesep=',            menu: 'Separation between nodes, in inches [G]'},
    \ #{word: 'orientation=',        menu: 'Node rotation angle [N]'},
    \ #{word: 'peripheries=',        menu: 'Number of node boundaries [N]'},
    \ #{word: 'rank=',               menu: '[G]'},
    \ #{word: 'rankdir=',            menu: '[G]'},
    \ #{word: 'ranksep=',            menu: 'Separation between ranks, in inches [G]'},
    \ #{word: 'ratio=',              menu: 'Aspect ratio [G]'},
    \ #{word: 'regular=',            menu: 'Force polygon to be regular [N]'},
    \ #{word: 'rotate=',             menu: 'If 90, set orientation to landscape [G]'},
    \ #{word: 'samehead=',           menu: '[E]'},
    \ #{word: 'sametail=',           menu: '[E]'},
    \ #{word: 'shape=',              menu: 'Node shape [N]'},
    \ #{word: 'shapefile=',          menu: 'External custom shape file [N]'},
    \ #{word: 'sides=',              menu: 'Number of sides for shape=polygon [N]'},
    \ #{word: 'skew=',               menu: 'Skewing node for for shape=polygon [N]'},
    \ #{word: 'style=',              menu: 'Graphics options [E,N]'},
    \ #{word: 'taillabel=',          menu: 'Label placed near tail of edge [E]'},
    \ #{word: 'tailport=',           menu: 'Where on the node to attach tail of edge [E]'},
    \ #{word: 'weight=',             menu: 'Integer cost of stretching an edge [E]'},
    \ #{word: 'width=',              menu: 'width in inches [N]'},
    \ ]

" boolean {{{2

let s:BOOLEAN = [
    \ #{word: 'true'},
    \ #{word: 'false'},
    \ ]

" color {{{2

let s:COLOR = [
    \ #{word: 'aliceblue'},
    \ #{word: 'antiquewhite'},
    \ #{word: 'antiquewhite1'},
    \ #{word: 'antiquewhite2'},
    \ #{word: 'antiquewhite3'},
    \ #{word: 'antiquewhite4'},
    \ #{word: 'aquamarine'},
    \ #{word: 'aquamarine1'},
    \ #{word: 'aquamarine2'},
    \ #{word: 'aquamarine3'},
    \ #{word: 'aquamarine4'},
    \ #{word: 'azure'},
    \ #{word: 'azure1'},
    \ #{word: 'azure2'},
    \ #{word: 'azure3'},
    \ #{word: 'azure4'},
    \ #{word: 'beige'},
    \ #{word: 'bisque'},
    \ #{word: 'bisque1'},
    \ #{word: 'bisque2'},
    \ #{word: 'bisque3'},
    \ #{word: 'bisque4'},
    \ #{word: 'black'},
    \ #{word: 'blanchedalmond'},
    \ #{word: 'blue'},
    \ #{word: 'blue1'},
    \ #{word: 'blue2'},
    \ #{word: 'blue3'},
    \ #{word: 'blue4'},
    \ #{word: 'blueviolet'},
    \ #{word: 'brown'},
    \ #{word: 'brown1'},
    \ #{word: 'brown2'},
    \ #{word: 'brown3'},
    \ #{word: 'brown4'},
    \ #{word: 'burlywood'},
    \ #{word: 'burlywood1'},
    \ #{word: 'burlywood2'},
    \ #{word: 'burlywood3'},
    \ #{word: 'burlywood4'},
    \ #{word: 'cadetblue'},
    \ #{word: 'cadetblue1'},
    \ #{word: 'cadetblue2'},
    \ #{word: 'cadetblue3'},
    \ #{word: 'cadetblue4'},
    \ #{word: 'chartreuse'},
    \ #{word: 'chartreuse1'},
    \ #{word: 'chartreuse2'},
    \ #{word: 'chartreuse3'},
    \ #{word: 'chartreuse4'},
    \ #{word: 'chocolate'},
    \ #{word: 'chocolate1'},
    \ #{word: 'chocolate2'},
    \ #{word: 'chocolate3'},
    \ #{word: 'chocolate4'},
    \ #{word: 'coral'},
    \ #{word: 'coral1'},
    \ #{word: 'coral2'},
    \ #{word: 'coral3'},
    \ #{word: 'coral4'},
    \ #{word: 'cornflowerblue'},
    \ #{word: 'cornsilk'},
    \ #{word: 'cornsilk1'},
    \ #{word: 'cornsilk2'},
    \ #{word: 'cornsilk3'},
    \ #{word: 'cornsilk4'},
    \ #{word: 'crimson'},
    \ #{word: 'cyan'},
    \ #{word: 'cyan1'},
    \ #{word: 'cyan2'},
    \ #{word: 'cyan3'},
    \ #{word: 'cyan4'},
    \ #{word: 'darkgoldenrod'},
    \ #{word: 'darkgoldenrod1'},
    \ #{word: 'darkgoldenrod2'},
    \ #{word: 'darkgoldenrod3'},
    \ #{word: 'darkgoldenrod4'},
    \ #{word: 'darkgreen'},
    \ #{word: 'darkkhaki'},
    \ #{word: 'darkolivegreen'},
    \ #{word: 'darkolivegreen1'},
    \ #{word: 'darkolivegreen2'},
    \ #{word: 'darkolivegreen3'},
    \ #{word: 'darkolivegreen4'},
    \ #{word: 'darkorange'},
    \ #{word: 'darkorange1'},
    \ #{word: 'darkorange2'},
    \ #{word: 'darkorange3'},
    \ #{word: 'darkorange4'},
    \ #{word: 'darkorchid'},
    \ #{word: 'darkorchid1'},
    \ #{word: 'darkorchid2'},
    \ #{word: 'darkorchid3'},
    \ #{word: 'darkorchid4'},
    \ #{word: 'darksalmon'},
    \ #{word: 'darkseagreen'},
    \ #{word: 'darkseagreen1'},
    \ #{word: 'darkseagreen2'},
    \ #{word: 'darkseagreen3'},
    \ #{word: 'darkseagreen4'},
    \ #{word: 'darkslateblue'},
    \ #{word: 'darkslategray'},
    \ #{word: 'darkslategray1'},
    \ #{word: 'darkslategray2'},
    \ #{word: 'darkslategray3'},
    \ #{word: 'darkslategray4'},
    \ #{word: 'darkslategrey'},
    \ #{word: 'darkturquoise'},
    \ #{word: 'darkviolet'},
    \ #{word: 'deeppink'},
    \ #{word: 'deeppink1'},
    \ #{word: 'deeppink2'},
    \ #{word: 'deeppink3'},
    \ #{word: 'deeppink4'},
    \ #{word: 'deepskyblue'},
    \ #{word: 'deepskyblue1'},
    \ #{word: 'deepskyblue2'},
    \ #{word: 'deepskyblue3'},
    \ #{word: 'deepskyblue4'},
    \ #{word: 'dimgray'},
    \ #{word: 'dimgrey'},
    \ #{word: 'dodgerblue'},
    \ #{word: 'dodgerblue1'},
    \ #{word: 'dodgerblue2'},
    \ #{word: 'dodgerblue3'},
    \ #{word: 'dodgerblue4'},
    \ #{word: 'firebrick'},
    \ #{word: 'firebrick1'},
    \ #{word: 'firebrick2'},
    \ #{word: 'firebrick3'},
    \ #{word: 'firebrick4'},
    \ #{word: 'floralwhite'},
    \ #{word: 'forestgreen'},
    \ #{word: 'gainsboro'},
    \ #{word: 'ghostwhite'},
    \ #{word: 'gold'},
    \ #{word: 'gold1'},
    \ #{word: 'gold2'},
    \ #{word: 'gold3'},
    \ #{word: 'gold4'},
    \ #{word: 'goldenrod'},
    \ #{word: 'goldenrod1'},
    \ #{word: 'goldenrod2'},
    \ #{word: 'goldenrod3'},
    \ #{word: 'goldenrod4'},
    \ #{word: 'gray'},
    \ #{word: 'gray0'},
    \ #{word: 'gray1'},
    \ #{word: 'gray10'},
    \ #{word: 'gray100'},
    \ #{word: 'gray11'},
    \ #{word: 'gray12'},
    \ #{word: 'gray13'},
    \ #{word: 'gray14'},
    \ #{word: 'gray15'},
    \ #{word: 'gray16'},
    \ #{word: 'gray17'},
    \ #{word: 'gray18'},
    \ #{word: 'gray19'},
    \ #{word: 'gray2'},
    \ #{word: 'gray20'},
    \ #{word: 'gray21'},
    \ #{word: 'gray22'},
    \ #{word: 'gray23'},
    \ #{word: 'gray24'},
    \ #{word: 'gray25'},
    \ #{word: 'gray26'},
    \ #{word: 'gray27'},
    \ #{word: 'gray28'},
    \ #{word: 'gray29'},
    \ #{word: 'gray3'},
    \ #{word: 'gray30'},
    \ #{word: 'gray31'},
    \ #{word: 'gray32'},
    \ #{word: 'gray33'},
    \ #{word: 'gray34'},
    \ #{word: 'gray35'},
    \ #{word: 'gray36'},
    \ #{word: 'gray37'},
    \ #{word: 'gray38'},
    \ #{word: 'gray39'},
    \ #{word: 'gray4'},
    \ #{word: 'gray40'},
    \ #{word: 'gray41'},
    \ #{word: 'gray42'},
    \ #{word: 'gray43'},
    \ #{word: 'gray44'},
    \ #{word: 'gray45'},
    \ #{word: 'gray46'},
    \ #{word: 'gray47'},
    \ #{word: 'gray48'},
    \ #{word: 'gray49'},
    \ #{word: 'gray5'},
    \ #{word: 'gray50'},
    \ #{word: 'gray51'},
    \ #{word: 'gray52'},
    \ #{word: 'gray53'},
    \ #{word: 'gray54'},
    \ #{word: 'gray55'},
    \ #{word: 'gray56'},
    \ #{word: 'gray57'},
    \ #{word: 'gray58'},
    \ #{word: 'gray59'},
    \ #{word: 'gray6'},
    \ #{word: 'gray60'},
    \ #{word: 'gray61'},
    \ #{word: 'gray62'},
    \ #{word: 'gray63'},
    \ #{word: 'gray64'},
    \ #{word: 'gray65'},
    \ #{word: 'gray66'},
    \ #{word: 'gray67'},
    \ #{word: 'gray68'},
    \ #{word: 'gray69'},
    \ #{word: 'gray7'},
    \ #{word: 'gray70'},
    \ #{word: 'gray71'},
    \ #{word: 'gray72'},
    \ #{word: 'gray73'},
    \ #{word: 'gray74'},
    \ #{word: 'gray75'},
    \ #{word: 'gray76'},
    \ #{word: 'gray77'},
    \ #{word: 'gray78'},
    \ #{word: 'gray79'},
    \ #{word: 'gray8'},
    \ #{word: 'gray80'},
    \ #{word: 'gray81'},
    \ #{word: 'gray82'},
    \ #{word: 'gray83'},
    \ #{word: 'gray84'},
    \ #{word: 'gray85'},
    \ #{word: 'gray86'},
    \ #{word: 'gray87'},
    \ #{word: 'gray88'},
    \ #{word: 'gray89'},
    \ #{word: 'gray9'},
    \ #{word: 'gray90'},
    \ #{word: 'gray91'},
    \ #{word: 'gray92'},
    \ #{word: 'gray93'},
    \ #{word: 'gray94'},
    \ #{word: 'gray95'},
    \ #{word: 'gray96'},
    \ #{word: 'gray97'},
    \ #{word: 'gray98'},
    \ #{word: 'gray99'},
    \ #{word: 'green'},
    \ #{word: 'green1'},
    \ #{word: 'green2'},
    \ #{word: 'green3'},
    \ #{word: 'green4'},
    \ #{word: 'greenyellow'},
    \ #{word: 'grey'},
    \ #{word: 'grey0'},
    \ #{word: 'grey1'},
    \ #{word: 'grey10'},
    \ #{word: 'grey100'},
    \ #{word: 'grey11'},
    \ #{word: 'grey12'},
    \ #{word: 'grey13'},
    \ #{word: 'grey14'},
    \ #{word: 'grey15'},
    \ #{word: 'grey16'},
    \ #{word: 'grey17'},
    \ #{word: 'grey18'},
    \ #{word: 'grey19'},
    \ #{word: 'grey2'},
    \ #{word: 'grey20'},
    \ #{word: 'grey21'},
    \ #{word: 'grey22'},
    \ #{word: 'grey23'},
    \ #{word: 'grey24'},
    \ #{word: 'grey25'},
    \ #{word: 'grey26'},
    \ #{word: 'grey27'},
    \ #{word: 'grey28'},
    \ #{word: 'grey29'},
    \ #{word: 'grey3'},
    \ #{word: 'grey30'},
    \ #{word: 'grey31'},
    \ #{word: 'grey32'},
    \ #{word: 'grey33'},
    \ #{word: 'grey34'},
    \ #{word: 'grey35'},
    \ #{word: 'grey36'},
    \ #{word: 'grey37'},
    \ #{word: 'grey38'},
    \ #{word: 'grey39'},
    \ #{word: 'grey4'},
    \ #{word: 'grey40'},
    \ #{word: 'grey41'},
    \ #{word: 'grey42'},
    \ #{word: 'grey43'},
    \ #{word: 'grey44'},
    \ #{word: 'grey45'},
    \ #{word: 'grey46'},
    \ #{word: 'grey47'},
    \ #{word: 'grey48'},
    \ #{word: 'grey49'},
    \ #{word: 'grey5'},
    \ #{word: 'grey50'},
    \ #{word: 'grey51'},
    \ #{word: 'grey52'},
    \ #{word: 'grey53'},
    \ #{word: 'grey54'},
    \ #{word: 'grey55'},
    \ #{word: 'grey56'},
    \ #{word: 'grey57'},
    \ #{word: 'grey58'},
    \ #{word: 'grey59'},
    \ #{word: 'grey6'},
    \ #{word: 'grey60'},
    \ #{word: 'grey61'},
    \ #{word: 'grey62'},
    \ #{word: 'grey63'},
    \ #{word: 'grey64'},
    \ #{word: 'grey65'},
    \ #{word: 'grey66'},
    \ #{word: 'grey67'},
    \ #{word: 'grey68'},
    \ #{word: 'grey69'},
    \ #{word: 'grey7'},
    \ #{word: 'grey70'},
    \ #{word: 'grey71'},
    \ #{word: 'grey72'},
    \ #{word: 'grey73'},
    \ #{word: 'grey74'},
    \ #{word: 'grey75'},
    \ #{word: 'grey76'},
    \ #{word: 'grey77'},
    \ #{word: 'grey78'},
    \ #{word: 'grey79'},
    \ #{word: 'grey8'},
    \ #{word: 'grey80'},
    \ #{word: 'grey81'},
    \ #{word: 'grey82'},
    \ #{word: 'grey83'},
    \ #{word: 'grey84'},
    \ #{word: 'grey85'},
    \ #{word: 'grey86'},
    \ #{word: 'grey87'},
    \ #{word: 'grey88'},
    \ #{word: 'grey89'},
    \ #{word: 'grey9'},
    \ #{word: 'grey90'},
    \ #{word: 'grey91'},
    \ #{word: 'grey92'},
    \ #{word: 'grey93'},
    \ #{word: 'grey94'},
    \ #{word: 'grey95'},
    \ #{word: 'grey96'},
    \ #{word: 'grey97'},
    \ #{word: 'grey98'},
    \ #{word: 'grey99'},
    \ #{word: 'honeydew'},
    \ #{word: 'honeydew1'},
    \ #{word: 'honeydew2'},
    \ #{word: 'honeydew3'},
    \ #{word: 'honeydew4'},
    \ #{word: 'hotpink'},
    \ #{word: 'hotpink1'},
    \ #{word: 'hotpink2'},
    \ #{word: 'hotpink3'},
    \ #{word: 'hotpink4'},
    \ #{word: 'indianred'},
    \ #{word: 'indianred1'},
    \ #{word: 'indianred2'},
    \ #{word: 'indianred3'},
    \ #{word: 'indianred4'},
    \ #{word: 'indigo'},
    \ #{word: 'invis'},
    \ #{word: 'ivory'},
    \ #{word: 'ivory1'},
    \ #{word: 'ivory2'},
    \ #{word: 'ivory3'},
    \ #{word: 'ivory4'},
    \ #{word: 'khaki'},
    \ #{word: 'khaki1'},
    \ #{word: 'khaki2'},
    \ #{word: 'khaki3'},
    \ #{word: 'khaki4'},
    \ #{word: 'lavender'},
    \ #{word: 'lavenderblush'},
    \ #{word: 'lavenderblush1'},
    \ #{word: 'lavenderblush2'},
    \ #{word: 'lavenderblush3'},
    \ #{word: 'lavenderblush4'},
    \ #{word: 'lawngreen'},
    \ #{word: 'lemonchiffon'},
    \ #{word: 'lemonchiffon1'},
    \ #{word: 'lemonchiffon2'},
    \ #{word: 'lemonchiffon3'},
    \ #{word: 'lemonchiffon4'},
    \ #{word: 'lightblue'},
    \ #{word: 'lightblue1'},
    \ #{word: 'lightblue2'},
    \ #{word: 'lightblue3'},
    \ #{word: 'lightblue4'},
    \ #{word: 'lightcoral'},
    \ #{word: 'lightcyan'},
    \ #{word: 'lightcyan1'},
    \ #{word: 'lightcyan2'},
    \ #{word: 'lightcyan3'},
    \ #{word: 'lightcyan4'},
    \ #{word: 'lightgoldenrod'},
    \ #{word: 'lightgoldenrod1'},
    \ #{word: 'lightgoldenrod2'},
    \ #{word: 'lightgoldenrod3'},
    \ #{word: 'lightgoldenrod4'},
    \ #{word: 'lightgoldenrodyellow'},
    \ #{word: 'lightgray'},
    \ #{word: 'lightgrey'},
    \ #{word: 'lightpink'},
    \ #{word: 'lightpink1'},
    \ #{word: 'lightpink2'},
    \ #{word: 'lightpink3'},
    \ #{word: 'lightpink4'},
    \ #{word: 'lightsalmon'},
    \ #{word: 'lightsalmon1'},
    \ #{word: 'lightsalmon2'},
    \ #{word: 'lightsalmon3'},
    \ #{word: 'lightsalmon4'},
    \ #{word: 'lightseagreen'},
    \ #{word: 'lightskyblue'},
    \ #{word: 'lightskyblue1'},
    \ #{word: 'lightskyblue2'},
    \ #{word: 'lightskyblue3'},
    \ #{word: 'lightskyblue4'},
    \ #{word: 'lightslateblue'},
    \ #{word: 'lightslategray'},
    \ #{word: 'lightslategrey'},
    \ #{word: 'lightsteelblue'},
    \ #{word: 'lightsteelblue1'},
    \ #{word: 'lightsteelblue2'},
    \ #{word: 'lightsteelblue3'},
    \ #{word: 'lightsteelblue4'},
    \ #{word: 'lightyellow'},
    \ #{word: 'lightyellow1'},
    \ #{word: 'lightyellow2'},
    \ #{word: 'lightyellow3'},
    \ #{word: 'lightyellow4'},
    \ #{word: 'limegreen'},
    \ #{word: 'linen'},
    \ #{word: 'magenta'},
    \ #{word: 'magenta1'},
    \ #{word: 'magenta2'},
    \ #{word: 'magenta3'},
    \ #{word: 'magenta4'},
    \ #{word: 'maroon'},
    \ #{word: 'maroon1'},
    \ #{word: 'maroon2'},
    \ #{word: 'maroon3'},
    \ #{word: 'maroon4'},
    \ #{word: 'mediumaquamarine'},
    \ #{word: 'mediumblue'},
    \ #{word: 'mediumorchid'},
    \ #{word: 'mediumorchid1'},
    \ #{word: 'mediumorchid2'},
    \ #{word: 'mediumorchid3'},
    \ #{word: 'mediumorchid4'},
    \ #{word: 'mediumpurple'},
    \ #{word: 'mediumpurple1'},
    \ #{word: 'mediumpurple2'},
    \ #{word: 'mediumpurple3'},
    \ #{word: 'mediumpurple4'},
    \ #{word: 'mediumseagreen'},
    \ #{word: 'mediumslateblue'},
    \ #{word: 'mediumspringgreen'},
    \ #{word: 'mediumturquoise'},
    \ #{word: 'mediumvioletred'},
    \ #{word: 'midnightblue'},
    \ #{word: 'mintcream'},
    \ #{word: 'mistyrose'},
    \ #{word: 'mistyrose1'},
    \ #{word: 'mistyrose2'},
    \ #{word: 'mistyrose3'},
    \ #{word: mistyrose4},
    \ #{word: 'moccasin'},
    \ #{word: 'navajowhite'},
    \ #{word: 'navajowhite1'},
    \ #{word: 'navajowhite2'},
    \ #{word: 'navajowhite3'},
    \ #{word: 'navajowhite4'},
    \ #{word: 'navy'},
    \ #{word: 'navyblue'},
    \ #{word: 'none'},
    \ #{word: 'oldlace'},
    \ #{word: 'olivedrab'},
    \ #{word: 'olivedrab1'},
    \ #{word: 'olivedrab2'},
    \ #{word: 'olivedrab3'},
    \ #{word: 'olivedrab4'},
    \ #{word: 'orange'},
    \ #{word: 'orange1'},
    \ #{word: 'orange2'},
    \ #{word: 'orange3'},
    \ #{word: 'orange4'},
    \ #{word: 'orangered'},
    \ #{word: 'orangered1'},
    \ #{word: 'orangered2'},
    \ #{word: 'orangered3'},
    \ #{word: 'orangered4'},
    \ #{word: 'orchid'},
    \ #{word: 'orchid1'},
    \ #{word: 'orchid2'},
    \ #{word: 'orchid3'},
    \ #{word: 'orchid4'},
    \ #{word: 'palegoldenrod'},
    \ #{word: 'palegreen'},
    \ #{word: 'palegreen1'},
    \ #{word: 'palegreen2'},
    \ #{word: 'palegreen3'},
    \ #{word: 'palegreen4'},
    \ #{word: 'paleturquoise'},
    \ #{word: 'paleturquoise1'},
    \ #{word: 'paleturquoise2'},
    \ #{word: 'paleturquoise3'},
    \ #{word: 'paleturquoise4'},
    \ #{word: 'palevioletred'},
    \ #{word: 'palevioletred1'},
    \ #{word: 'palevioletred2'},
    \ #{word: 'palevioletred3'},
    \ #{word: 'palevioletred4'},
    \ #{word: 'papayawhip'},
    \ #{word: 'peachpuff'},
    \ #{word: 'peachpuff1'},
    \ #{word: 'peachpuff2'},
    \ #{word: 'peachpuff3'},
    \ #{word: 'peachpuff4'},
    \ #{word: 'peru'},
    \ #{word: 'pink'},
    \ #{word: 'pink1'},
    \ #{word: 'pink2'},
    \ #{word: 'pink3'},
    \ #{word: 'pink4'},
    \ #{word: 'plum'},
    \ #{word: 'plum1'},
    \ #{word: 'plum2'},
    \ #{word: 'plum3'},
    \ #{word: 'plum4'},
    \ #{word: 'powderblue'},
    \ #{word: 'purple'},
    \ #{word: 'purple1'},
    \ #{word: 'purple2'},
    \ #{word: 'purple3'},
    \ #{word: 'purple4'},
    \ #{word: 'red'},
    \ #{word: 'red1'},
    \ #{word: 'red2'},
    \ #{word: 'red3'},
    \ #{word: 'red4'},
    \ #{word: 'rosybrown'},
    \ #{word: 'rosybrown1'},
    \ #{word: 'rosybrown2'},
    \ #{word: 'rosybrown3'},
    \ #{word: 'rosybrown4'},
    \ #{word: 'royalblue'},
    \ #{word: 'royalblue1'},
    \ #{word: 'royalblue2'},
    \ #{word: 'royalblue3'},
    \ #{word: 'royalblue4'},
    \ #{word: 'saddlebrown'},
    \ #{word: 'salmon'},
    \ #{word: 'salmon1'},
    \ #{word: 'salmon2'},
    \ #{word: 'salmon3'},
    \ #{word: 'salmon4'},
    \ #{word: 'sandybrown'},
    \ #{word: 'seagreen'},
    \ #{word: 'seagreen1'},
    \ #{word: 'seagreen2'},
    \ #{word: 'seagreen3'},
    \ #{word: 'seagreen4'},
    \ #{word: 'seashell'},
    \ #{word: 'seashell1'},
    \ #{word: 'seashell2'},
    \ #{word: 'seashell3'},
    \ #{word: 'seashell4'},
    \ #{word: 'sienna'},
    \ #{word: 'sienna1'},
    \ #{word: 'sienna2'},
    \ #{word: 'sienna3'},
    \ #{word: 'sienna4'},
    \ #{word: 'skyblue'},
    \ #{word: 'skyblue1'},
    \ #{word: 'skyblue2'},
    \ #{word: 'skyblue3'},
    \ #{word: 'skyblue4'},
    \ #{word: 'slateblue'},
    \ #{word: 'slateblue1'},
    \ #{word: 'slateblue2'},
    \ #{word: 'slateblue3'},
    \ #{word: 'slateblue4'},
    \ #{word: 'slategray'},
    \ #{word: 'slategray1'},
    \ #{word: 'slategray2'},
    \ #{word: 'slategray3'},
    \ #{word: 'slategray4'},
    \ #{word: 'slategrey'},
    \ #{word: 'snow'},
    \ #{word: 'snow1'},
    \ #{word: 'snow2'},
    \ #{word: 'snow3'},
    \ #{word: 'snow4'},
    \ #{word: 'springgreen'},
    \ #{word: 'springgreen1'},
    \ #{word: 'springgreen2'},
    \ #{word: 'springgreen3'},
    \ #{word: 'springgreen4'},
    \ #{word: 'steelblue'},
    \ #{word: 'steelblue1'},
    \ #{word: 'steelblue2'},
    \ #{word: 'steelblue3'},
    \ #{word: 'steelblue4'},
    \ #{word: 'tan'},
    \ #{word: 'tan1'},
    \ #{word: 'tan2'},
    \ #{word: 'tan3'},
    \ #{word: 'tan4'},
    \ #{word: 'thistle'},
    \ #{word: 'thistle1'},
    \ #{word: 'thistle2'},
    \ #{word: 'thistle3'},
    \ #{word: 'thistle4'},
    \ #{word: 'tomato'},
    \ #{word: 'tomato1'},
    \ #{word: 'tomato2'},
    \ #{word: 'tomato3'},
    \ #{word: 'tomato4'},
    \ #{word: 'transparent'},
    \ #{word: 'turquoise'},
    \ #{word: 'turquoise1'},
    \ #{word: 'turquoise2'},
    \ #{word: 'turquoise3'},
    \ #{word: 'turquoise4'},
    \ #{word: 'violet'},
    \ #{word: 'violetred'},
    \ #{word: 'violetred1'},
    \ #{word: 'violetred2'},
    \ #{word: 'violetred3'},
    \ #{word: 'violetred4'},
    \ #{word: 'wheat'},
    \ #{word: 'wheat1'},
    \ #{word: 'wheat2'},
    \ #{word: 'wheat3'},
    \ #{word: 'wheat4'},
    \ #{word: 'white'},
    \ #{word: 'whitesmoke'},
    \ #{word: 'yellow'},
    \ #{word: 'yellow1'},
    \ #{word: 'yellow2'},
    \ #{word: 'yellow3'},
    \ #{word: 'yellow4'},
    \ #{word: 'yellowgreen'},
    \ ]

" direction {{{2

" FIXME:
" Not used anywhere.
let s:DIR = [
    \ #{word: 'forward'},
    \ #{word: 'back'},
    \ #{word: 'both'},
    \ #{word: 'none'},
    \ ]

" font {{{2

let s:FONT = [
    \ #{abbr: 'Courier',           word: '"Courier"'},
    \ #{abbr: 'Courier-Bold',      word: '"Courier-Bold"'},
    \ #{abbr: 'Courier-Oblique',   word: '"Courier-Oblique"'},
    \ #{abbr: 'Helvetica',         word: '"Helvetica"'},
    \ #{abbr: 'Helvetica-Bold',    word: '"Helvetica-Bold"'},
    \ #{abbr: 'Helvetica-Narrow',  word: '"Helvetica-Narrow"'},
    \ #{abbr: 'Helvetica-Oblique', word: '"Helvetica-Oblique"'},
    \ #{abbr: 'Symbol',            word: '"Symbol"'},
    \ #{abbr: 'Times-Bold',        word: '"Times-Bold"'},
    \ #{abbr: 'Times-BoldItalic',  word: '"Times-BoldItalic"'},
    \ #{abbr: 'Times-Italic',      word: '"Times-Italic"'},
    \ #{abbr: 'Times-Roman',       word: '"Times-Roman"'},
    \ ]

" justification {{{2

let s:JUST = [
    \ #{word: 'centered'},
    \ #{word: 'l'},
    \ #{word: 'r'},
    \ ]

" location {{{2

let s:LOC = [
    \ #{word: 'b', menu: 'bottom'},
    \ #{word: 'c', menu: 'center'},
    \ #{word: 't', menu: 'top'},
    \ ]

" port {{{2

let s:PORT = [
    \ #{word: '_', menu: 'appropriate side or center (default)'},
    \ #{word: 'c', menu: 'center'},
    \ #{word: 'e'},
    \ #{word: 'n'},
    \ #{word: 'ne'},
    \ #{word: 'nw'},
    \ #{word: 's'},
    \ #{word: 'se'},
    \ #{word: 'sw'},
    \ #{word: 'w'},
    \ ]

" rank {{{2

let s:RANK = [
    \ #{word: 'same'},
    \ #{word: 'min'},
    \ #{word: 'max'},
    \ #{word: 'source'},
    \ #{word: 'sink'},
    \ ]

" rankdir {{{2

let s:RANKDIR = [
    \ #{word: 'BT'},
    \ #{word: 'LR'},
    \ #{word: 'RL'},
    \ #{word: 'TB'},
    \ ]

" shape {{{2

let s:SHAPE = [
    \ #{word: 'Mcircle'},
    \ #{word: 'Mdiamond'},
    \ #{word: 'Mrecord'},
    \ #{word: 'Msquare'},
    \ #{word: 'assembly'},
    \ #{word: 'box'},
    \ #{word: 'box3d'},
    \ #{word: 'cds'},
    \ #{word: 'circle'},
    \ #{word: 'component'},
    \ #{word: 'cylinder'},
    \ #{word: 'diamond'},
    \ #{word: 'doublecircle'},
    \ #{word: 'doubleoctagon'},
    \ #{word: 'egg'},
    \ #{word: 'ellipse'},
    \ #{word: 'fivepoverhang'},
    \ #{word: 'folder'},
    \ #{word: 'hexagon'},
    \ #{word: 'house'},
    \ #{word: 'insulator'},
    \ #{word: 'invhouse'},
    \ #{word: 'invtrapezium'},
    \ #{word: 'invtriangle'},
    \ #{word: 'larrow'},
    \ #{word: 'lpromoter'},
    \ #{word: 'none'},
    \ #{word: 'note'},
    \ #{word: 'noverhang'},
    \ #{word: 'octagon'},
    \ #{word: 'oval'},
    \ #{word: 'parallelogram'},
    \ #{word: 'pentagon'},
    \ #{word: 'plain'},
    \ #{word: 'plaintext'},
    \ #{word: 'point'},
    \ #{word: 'polygon'},
    \ #{word: 'primersite'},
    \ #{word: 'promoter'},
    \ #{word: 'proteasesite'},
    \ #{word: 'proteinstab'},
    \ #{word: 'rarrow'},
    \ #{word: 'record'},
    \ #{word: 'rect'},
    \ #{word: 'rectangle'},
    \ #{word: 'restrictionsite'},
    \ #{word: 'ribosite'},
    \ #{word: 'rnastab'},
    \ #{word: 'rpromoter'},
    \ #{word: 'septagon'},
    \ #{word: 'signature'},
    \ #{word: 'square'},
    \ #{word: 'star'},
    \ #{word: 'tab'},
    \ #{word: 'terminator'},
    \ #{word: 'threepoverhang'},
    \ #{word: 'trapezium'},
    \ #{word: 'triangle'},
    \ #{word: 'tripleoctagon'},
    \ #{word: 'underline'},
    \ #{word: 'utr'},
    \ ]

" style {{{2

let s:STYLE = [
    \ #{word: 'tapered',   menu: '[E]'},
    \ #{word: 'radial',    menu: '[N,G,C]'},
    \ #{word: 'diagonals', menu: '[N]'},
    \ #{word: 'wedged',    menu: '[N]'},
    \ #{word: 'filled',    menu: '[N,C]'},
    \ #{word: 'rounded',   menu: '[N,C]'},
    \ #{word: 'striped',   menu: '[N,C]'},
    \ #{word: 'bold',      menu: '[E,N]'},
    \ #{word: 'dashed',    menu: '[E,N]'},
    \ #{word: 'dotted',    menu: '[E,N]'},
    \ #{word: 'invis',     menu: '[E,N]'},
    \ #{word: 'solid',     menu: '[E,N]'},
    \ ]

fu graph#cmd(action, line1, line2) abort "{{{1
    sil update
    let cmd = matchstr(a:action, '-compile\s*\zs\S\+')
    if empty(cmd)
        let cmd = 'dot'
    endif

    if a:action =~# '-compile'
        call s:compile(cmd, a:line1, a:line2)
    else
        let funcname = matchstr(a:action, '-\zs\S\+')
        if empty(funcname) || !exists('*s:' .. funcname)
            return
        elseif funcname is# 'show'
            call s:show(cmd, a:line1, a:line2)
        elseif funcname is# 'interactive'
            call s:interactive()
        endif
    endif
endfu

fu graph#cmd_complete(arglead, cmdline, _p) abort "{{{1
    let options =<< trim END
        -compile
        -interactive
        -show
    END

    return a:arglead[0] is# '-' || empty(a:arglead) && a:cmdline !~# '\%(-compile\|-show\)\s\+\w*$'
        \ ?     join(options, "\n")
        \ :     join(['circo', 'dot', 'dot2text', 'fdp', 'neato', 'sfdp', 'twopi'], "\n")
endfu

fu graph#omni_complete(findstart, base) abort "{{{1
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

        if line[withspacepos - 1] is# '='
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
            let labelstr = line[labelpos : withspacepos - 2]

            let s:completion_type = labelstr is# 'shape'
                \ ?     'SHAPE'
                \ : labelstr =~ 'fontname'
                \ ?     'FONT'
                \ : labelstr =~ 'color'
                \ ?     'COLOR'
                \ : labelstr is# 'arrowhead'
                \ ?     'ARROWHEAD'
                \ : labelstr is# 'rank'
                \ ?     'RANK'
                \ : labelstr is# 'headport' || labelstr is# 'tailport'
                \ ?     'PORT'
                \ : labelstr is# 'rankdir'
                \ ?     'RANKDIR'
                \ : labelstr is# 'style'
                \ ?     'STYLE'
                \ : labelstr is# 'labeljust'
                \ ?     'JUST'
                \ : index([
                \     'center',
                \     'compound',
                \     'concentrate',
                \     'constraint',
                \     'fixedsize',
                \     'labelfloat',
                \     'regular',
                \ ], labelstr) >= 0
                \ ?     'BOOLEAN'
                \ : labelstr is# 'labelloc'
                \ ?     'LOC'
                \ :     ''

        elseif line[withspacepos - 1] =~ ',\|\['
            " attr
            let attrstr=line[0 : withspacepos - 1]
            " skip spaces
            while line[withspacepos] =~ '\s'
                let withspacepos += 1
            endwhile

            let s:completion_type = attrstr =~ '^\s*node'
                \ ?     'attrnode'
                \ : attrstr =~ '^\s*edge'
                \ ?     'attredge'
                \ : attrstr =~ '\( -> \)\|\( -- \)'
                \ ?     'attredge'
                \ : attrstr =~ '^\s*graph'
                \ ?     'attrgraph'
                \ :     'attrnode'
        else
            let s:completion_type = ''
        endif

        return pos
    else

        if s:completion_type =~# '^attr'
            return copy(s:ATTRS)->filter({_, v -> stridx(v.word, a:base) == 0
                \ && v.menu =~ '\[.*' .. toupper(s:completion_type[4]) .. '.*\]' })
        elseif index([
            \ 'ARROWHEAD',
            \ 'BOOLEAN',
            \ 'COLOR',
            \ 'FONT',
            \ 'JUST',
            \ 'LOC',
            \ 'PORT',
            \ 'RANK',
            \ 'RANKDIR',
            \ 'SHAPE',
            \ 'STYLE',
            \ ], s:completion_type) == -1
            return []
        endif

        return copy(s:{s:completion_type})->filter({_, v -> stridx(v.word, a:base) == 0})
    endif
endfu

fu s:compile(cmd, line1, line2) abort "{{{1
    if !executable(a:cmd)
        try
            throw 'E8010: [graph]  filter not available: ' .. a:cmd
        finally
            return 'fail'
        endtry
    endif
    " FIXME:
    " The directory could be non writable.
    "
    " `filereadable()` is not the right check.
    "
    " Maybe the `pdf` file doesn't exist yet,  but that doesn't mean it can't be
    " created.  We need a condition to  test whether the directory exists and is
    " writable.

    " elseif !s:output_file()->filereadable()
    "     try
    "         throw 'E8011: [graph]  output file not writable ' .. s:output_file()
    "     finally
    "         return 'fail'
    "     endtry
    " endif

    let file = expand('%:p')
    if [a:line1, a:line2] !=# [1, line('$')]
        let lines = getline(a:line1, a:line2)
        let file = tempname()
        call writefile(lines, file)
    endif

    " FIXME:
    " We're building and executing the shell compilation command manually.
    " Shouldn't we use `:make` instead?
    " If not, then why do we configure `'mp'` in the `compiler/` directory.
    let logfile = tempname() .. '.log'
    sil call printf('(%s -T' .. s:FORMAT .. ' %s -o %s 2>&1) | tee %s',
        \ a:cmd,
        \ shellescape(file),
        \ s:output_file()->shellescape(),
        \ shellescape(logfile)
        \ )->system()

    if getfsize(logfile)
        exe 'cfile ' .. escape(logfile, ' \"!?''')
    endif
    call delete(logfile)
    return 1
endfu

fu graph#create_diagram() abort "{{{1
    let [col1, col2] = [col("'<"), col("'>")]
    let lnum = line('.')
    let line = getline('.')

    let pat = '.*\%' .. col1 .. 'c\zs.*\%' .. col2 .. 'c.\ze.*'
    let fname = getline('.')->matchstr(pat)->substitute('\s\+', '_', 'g')

    " prepend the selection with an open square bracket
    let line =substitute(line, '.*\%' .. col1 .. 'c\zs', '[', '')
    " prefix it with a closing square bracket
    let line = substitute(line, '.*\%' .. col2 .. 'c..\zs', ']', '')
    "                                               ││
    "                                               │└ to take into account the open square bracket
    "                                               │  we've just inserted
    "                                               │
    "                                               └ to include the last character in the selection
    "                                                 INSIDE the brackets

    let wiki_root = expand('%:p:h:h')
    let wikiname = expand('%:h:t')
    let path_to_wiki = wiki_root .. '/graph/' .. wikiname
    let path_to_dot = path_to_wiki .. '/src/' .. fname .. '.dot'

    let path_to_pdf = path_to_wiki .. '/' .. fname .. '.pdf'
    let path_to_pdf = substitute(path_to_pdf, '\V' .. $MY_WIKI, '$MY_WIKI', '')
    " append `(path_to_file.pdf)`
    let line = substitute(line, '.*\%' .. col2 .. 'c...\zs', '(' .. path_to_pdf .. ')', '')
    " \                     '(' .. fnamemodify(path, ':h')->substitute('\V' .. $MY_WIKI, '$MY_WIKI', '') .. '.pdf)',
    call setline(lnum, line)

    " open a split to write source code of diagram
    sp | exe 'e ' .. path_to_dot
endfu

fu graph#edit_diagram() abort "{{{1
    let col = col('.')
    " Used to extract `[five](six)`, when the cursor is on `six`:{{{
    "
    "     one [two](three) (four) [five](six) seven
    "                                     ^
    "}}}
    let pat =
        \   '\[[^)]*\%' .. col .. 'c[^)]*)'
        \ .. '\|'
        \ .. '\%' .. col .. 'c\[[^)]*)'

    let path = getline('.')->matchstr(pat)
    " used to extract `six` from `[five](six)`
    let path = matchstr(path, '\[.\{-}\](\zs.\{-}\ze)')
    let fname = fnamemodify(path, ':t:r') .. '.dot'
    let path = fnamemodify(path, ':h') .. '/src/' .. fname
    let path = substitute(path, '^\s*\.', expand('%:p:h'), '')

    "   ┌ in case the path contains an environment variable
    "   │
    if !expand(path)->filereadable()
        return
    endif

    sp | exe 'e ' .. path
    nno <buffer><expr><nowait> q reg_recording() != '' ? 'q' : '<cmd>q<cr>'
    au BufWritePost <buffer> ++once Graph -compile
endfu

fu s:interactive() abort "{{{1
    " FIXME:
    " Would it be possible to support other commands (neato, twopi, …)?

    " Interactive viewing.  "dot -Txlib  <file.gv>" uses inotify  to immediately
    " redraw image when the input file is changed.

    if !executable('dot')
        throw 'E8010: [graph]  filter not available: dot'
    endif

    sil call system('dot -Txlib ' .. expand('%:p:S') .. ' &')
endfu

fu s:output_file() abort "{{{1
    return expand('%:p:h:h') .. '/' .. expand('%:t:r') .. '.' .. s:FORMAT
endfu

fu s:show(cmd,line1,line2) abort "{{{1
    " if !s:output_file()->filereadable()
    "     call s:compile('dot')
    " endif

    if s:compile(a:cmd, a:line1, a:line2) is# 'fail'
        return
    endif

    if !executable(s:VIEWER)
        echoerr 'Viewer program not found: ' .. s:VIEWER
        return
    endif
    sil call system(s:VIEWER .. ' ' .. s:output_file()->shellescape() .. ' &')
endfu

fu graph#undo_ftplugin() abort "{{{1
    set cms< efm< mp< ofu<
    unlet! b:mc_chain

    nunmap <buffer> <bar>c
    xunmap <buffer> <bar>c
    nunmap <buffer> <bar>i
    nunmap <buffer> <bar>s
    xunmap <buffer> <bar>s

    delc Graph
endfu

