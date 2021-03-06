

element_info <- list(
  a                   = c("href"),
  animate             = c("attributeName", "attributeType", "from", "to", "dur", "repeatCount", 'begin', 'end', 'calcMode', 'values', 'keyTimes', 'keySplines', 'by'),
  animateMotion       = c("calcMode", "path", "keyPoints", "rotate", "origin" ),
  animateTransform    = c("attributeName", "attributeType", "by", "from", "to", "type", "dur", "repeatCount"),
  circle              = c("cx", "cy", "r"),
  clipPath            = c("id"),
  defs                = c(),
  desc                = c(),
  discard             = c("begin", "href"),
  ellipse             = c("cx", "cy", "rx", "ry"),
  feBlend             = c("in", "in2", "mode", "result"),
  feColorMatrix       = c("in", "type", "values", "result"),
  feComponentTransfer = c("in", "result"),
  feComposite         = c("in", "in2", "operator", "k1", "k2", "k3", "k4", "result"),
  feConvolveMatrix    = c("in", "order", "kernelMatrix", "divisor", "bias", "targetX", "targetY", "edgeMode", "kernelUnitLength", "preserveAlpha", "result"),
  feDiffuseLighting   = c("in", "surfaceScale", "diffuseConstant", "kernelUnitLength", "result"),
  feDisplacementMap   = c("in", "in2", "scale", "xChannelSelector", "yChannelSelector", "result"),
  feFlood             = c("flood_color", "flood_opacity", "result"),
  feFuncR             = c("type", "tableValues"),
  feFuncG             = c("type", "tableValues"),
  feFuncB             = c("type", "tableValues"),
  feFuncA             = c("type", "tableValues"),
  feGaussianBlur      = c("in", "stdDeviation", "edgeMode", "result"),
  feImage             = c("preserveAspectRatio", "xlink_href", "result"),
  feMerge             = c("result"),
  feMergeNode         = c("in"),
  feMorphology        = c("in", "operator", "radius", "result"),
  feOffset            = c("in", "dx", "dy", "result"),
  feSpecularLighting  = c("in", "surfaceScale", "specularConstant", "specularExponent", "kernelUnitLength", "result"),
  feTile              = c("in", "result"),
  feTurbulence        = c("type", "baseFrequency", "numOctaves", "seed", "stitchTiles", "result"),
  filter              = c("id", "x", "y", "width", "height", "filterRes", "filterUnits", "primitiveUnits",  "xlink_href"),
  foreignObject       = c("x", "y", "width", "height"),
  g                   = c("id"),
  image               = c("x", "y", "width", "height", "xlink_href", "preserveAspectRatio"),
  line                = c("x1", "y1", "x2", "y2"),
  linearGradient      = c("x1", "y1", "x2", "y2", "href", "gradientTransform", "gradientUnits", "spreadMethod"),
  marker              = c("refX", "refY", "markerWidth", "markerHeight", "markerUnits", "orient","preserveAspectRatio", "viewBox"),
  mask                = c("x", "y", "width", "height", "maskUnits", "maskContentUnits"),
  mpath               = c("xlink_href"),
  path                = c("d", "pathLength"),
  pattern             = c("id", "x", "y", "width", "height", "href", "patternUnits", "patternTransform", "preserveAspectRatio"),
  polygon             = c("xs", "ys", "points"),
  polyline            = c("xs", "ys", "points"),
  radialGradient      = c("id", "cx", "cy", "r", "fx", "fy", "fr", "href", "gradientUnits", "gradientTransform", "spreadMethod"),
  rect                = c("x", "y", "width", "height", "rx", "ry"),
  script              = c("type", "href"),
  set                 = c("to"),
  stop                = c("offset", "stop_color", "stop_opacity"),
  style               = c(),
  switch              = c(),
  symbol              = c("id", "x", "y", "width", "height", "refX", "refY", "preserveAspectRatio"),
  text                = c("x", "y", "dx", "dy", "rotate", "textWidth", "lengthAdjust"),
  textPath            = c("href", "path", "method", "side", "spacing", "startOffset", "textLength", "lengthAdjust"),
  title               = c(),
  use                 = c("x", "y", "width", "height", "href")
)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Add a method to the SVGElement class which creates a new child SVGElement of the specified type
#'
#' @param method_name name of method in SVGElement class
#' @param element_name the name of the SVG element to add
#' @param args character vector of argument names
#'
#' @importFrom glue glue
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
add_method <- function(method_name, element_name, args) {

  # Don't add a method:  'polygon' and 'polyline' are already defined on
  # SVGElement to be a little more R/vector friendly
  if (method_name %in% c('polygon', 'polyline')) {
    return()
  }

  if (length(args) == 0) {
    func_text <- glue("function(...) {{
    elem <- SVGElement$new('{element_name}', ...)
    self$append(elem)
    invisible(elem)
}}")
  } else {
    args[args == 'in'] <- 'in_'
    func_text <- glue("function(..., {paste(args, 'NULL', sep=' = ', collapse = ', ')}) {{
    elem <- SVGElement$new('{element_name}', ..., {paste(args, args, sep = ' = ', collapse = ', ')})
    self$append(elem)
    invisible(elem)
}}")
  }

  func <- eval(parse(text = func_text))

  SVGElement$set("public", method_name, func)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Dynamically add all the element creation methods to 'SVGElement' class
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for (element_name in names(element_info)) {
  element_args <- element_info[[element_name]]
  add_method(
    method_name  = element_name,
    element_name = element_name,
    args         = element_args
  )
}





#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Custom methods for polygon and polyline so that we could pass in more
# natural arguments from R
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SVGElement$set(
  "public", "polygon",
  function(xs = NULL, ys = NULL, points = NULL, ...) {

    if (is.null(points)) {
      points <- convert_args_to_points(xs, ys)
    }

    elem <- SVGElement$new('polygon', points = points, ...)
    self$append(elem)
    invisible(elem)
  }
)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Custom methods for polygon and polyline so that we could pass in more
# natural arguments from R
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SVGElement$set(
  "public", "polyline",
  function(xs = NULL, ys = NULL, points = NULL, ...) {

    if (is.null(points)) {
      points <- convert_args_to_points(xs, ys)
    }

    elem <- SVGElement$new('polyline', points = points, ...)
    self$append(elem)
    invisible(elem)
  }
)


