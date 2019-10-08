


# from: https://www.w3.org/TR/SVG/propidx.html
# from: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/Presentation
svg_properties <- list(
  list(
    name   = "alignment-baseline"        ,
    other  = NULL,
    values = c('auto', 'baseline', 'before-edge', 'text-before-edge', 'middle', 'central', 'after-edge', 'text-after-edge', 'ideographic', 'alphabetic', 'hanging', 'mathematical')),
  list(
    name   = "baseline-shift"            ,
    other  = c('percentage', 'length'),
    values = c('baseline', 'sub', 'super')),
  list(
    name   = "color"                     ,
    other  = c('color'),
    values = c()),
  list(
    name   = "color-interpolation"       ,
    other  = NULL,
    values = c('auto', 'sRGB', 'linearRGB')),
  list(
    name   = "color-rendering"           ,
    other  = NULL,
    values = c('auto', 'optimizeSpeed', 'optimizeQuality')),
  list(
    name   = "direction"                 ,
    other  = NULL,
    values = c('ltr', 'rtl')),
  list(
    name   = "display"                   ,
    other  = NULL,
    values = c('inline', 'block', 'list-item', 'run-in', 'compact', 'marker', 'table', 'inline-table', 'table-row-group', 'table-header-group', 'table-footer-group', 'table-row', 'table-column-group', 'table-column', 'table-cell', 'table-caption', 'none')),
  list(
    name   = "dominant-baseline"         ,
    other  = NULL,
    values = c('auto', 'use-script', 'no-change', 'reset-size', 'ideographic', 'alphabetic', 'hanging', 'mathematical', 'central', 'middle', 'text-after-edge', 'text-before-edge')),
  list(
    name   = "fill"                      ,
    other  = c('color'),
    values = c()),
  list(
    name   = "fill-opacity"              ,
    other  = c('alpha'),
    values = c()),
  list(
    name   = "fill-rule"                 ,
    other  = NULL,
    values = c('nonzero', 'evenodd')),
  list(
    name   = "font-variant"              ,
    other  = NULL,
    values = c('normal', 'small-caps')),
  list(
    name   = "glyph-orientation-vertical",
    other  = c('angle', 'number'),
    values = c('auto')),
  list(
    name   = "image-rendering"           ,
    other  = NULL,
    values = c('auto', 'optimizeSpeed', 'optimizeQuality')),
  list(
    name   = "line-height"               ,
    other  = c('number', 'length_percentage'),
    values = c('normal')),
  list(
    name   = "marker"                    ,
    other  = c('...'),
    values = c()),
  list(
    name   = "marker-end"                ,
    other  = c('url'),
    values = c('none')),
  list(
    name   = "marker-mid"                ,
    other  = c('url'),
    values = c('none')),
  list(
    name   = "marker-start"              ,
    other  = c('url'),
    values = c('none')),
  list(
    name   = "opacity"                   ,
    other  = c('alpha'),
    values = c()),
  list(
    name   = "overflow"                  ,
    other  = NULL,
    values = c('visible', 'hidden', 'scroll', 'auto')),
  list(
    name   = "paint-order"               ,
    other  = NULL,
    values = c('normal', 'fill', 'stroke', 'markers')),
  list(
    name   = "pointer-events"            ,
    other  = NULL,
    values = c('bounding_box', 'visiblePainted', 'visibleFill', 'visibleStroke', 'visible', 'visiblePainted', 'painted', 'fill', 'stroke', 'all', 'none')),
  list(
    name   = "shape-rendering"           ,
    other  = NULL,
    values = c('auto', 'optimizeSpeed', 'cispEdges', 'geometricPrecision')),
  list(
    name   = "stop-color"                ,
    other  = c('color'),
    values = c('currentColor')),
  list(
    name   = "stop-opacity"              ,
    other  = c('alpha'),
    values = c()),
  list(
    name   = "stroke"                    ,
    other  = 'color',
    values = c()),
  list(
    name   = "stroke-dasharray"          ,
    other  = c('dasharray'),
    values = c('none')),
  list(
    name   = "stroke-dashoffset"         ,
    other  = c('length_percentage'),
    values = c()),
  list(
    name   = "stroke-linecap"            ,
    other  = NULL,
    values = c('butt', 'round', 'square')),
  list(
    name   = "stroke-linejoin"           ,
    other  = NULL,
    values = c('miter', 'round', 'bevel')),
  list(
    name   = "stroke-miterlimit"         ,
    other  = c('number'),
    values = c()),
  list(
    name   = "stroke-opacity"            ,
    other  = c('alpha'),
    values = c()),
  list(
    name   = "stroke-width"              ,
    other  = c('length_percentage'),
    values = c()),
  list(
    name   = "text-anchor"               ,
    other  = NULL,
    values = c('start', 'middle', 'end')),
  list(
    name   = "text-decoration"           ,
    other  = NULL,
    values = c('none', 'underline', 'overline', 'line-through', 'blink')),
  list(
    name   = "text-rendering"            ,
    other  = NULL,
    values = c('auto', 'optimizeSpeed', 'optimizeLegibility', 'geometricPrecision')),
  list(
    name   = "vector-effect"             ,
    other  = NULL,
    values = c('non-scaling-stroke', 'none')),
  list(
    name   = "visibility"                ,
    other  = NULL,
    values = c('visible', 'hidden', 'collapse')),
  list(
    name   = "white-space"               ,
    other  = NULL,
    values = c('normal', 'pre', 'nowrap', 'pre-wrap', 'pre-line')),
  list(
    name   = "writing-mode"              ,
    other  = NULL,
    values = c('lr-tb', 'rl-tb', 'tb-rl', 'lr', 'rl', 'tb'))
)

