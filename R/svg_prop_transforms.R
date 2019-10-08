


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add transform helpers to the 'svg_prop' helper
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
svg_prop$transform <- list(
  matrix = function(a, b, c, d, e, f) {
    as_svg_property(list(transform = glue("matrix({a} {b} {c} {d} {e} {f})")))
  },

  translate = function(x, y=NULL) {
    if (is.null(y)) {
      as_svg_property(list(transform = glue("translate({x})")))
    } else {
      as_svg_property(list(transform = glue("translate({x} {y})")))
    }
  },

  scale = function(x, y=NULL) {
    if (is.null(y)) {
      as_svg_property(list(transform = glue("scale({x})")))
    } else {
      as_svg_property(list(transform = glue("scale({x} {y})")))
    }
  },

  rotate = function(a, x=NULL, y=NULL) {
    if (is.null(y) && is.null(x)) {
      as_svg_property(list(transform = glue("rotate({a})")))
    } else if (!is.null(y) && !is.null(x)) {
      as_svg_property(list(transform = glue("rotate({a} {x} {y})")))
    } else {
      stop("Bad transform rotate specification")
    }
  },

  skewX = function(a) {
    as_svg_property(list(transform = glue("skewX({a})")))
  },

  skewY = function(a) {
    as_svg_property(list(transform = glue("skewY({a})")))
  },

  set = create_first_arg_func('transform', args = c('transform'))
)



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add Transform methods to the SVGElement class
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SVGElement$set("public", "matrix", function(a, b, c, d, e, f) {
  self$update(transform = glue("matrix({a} {b} {c} {d} {e} {f})"))
  invisible(self)
})

SVGElement$set("public", "translate", function(x, y=NULL) {
  if (is.null(y)) {
    self$update(transform = glue("translate({x})"))
  } else {
    self$update(transform = glue("translate({x} {y})"))
  }
  invisible(self)
})

SVGElement$set("public", "scale", function(x, y=NULL) {
  if (is.null(y)) {
    self$update(transform = glue("scale({x})"))
  } else {
    self$update(transform = glue("scale({x} {y})"))
  }
  invisible(self)
})

SVGElement$set("public", "rotate", function(a, x=NULL, y=NULL) {
  if (is.null(y) && is.null(x)) {
    self$update(transform = glue("rotate({a})"))
  } else if (!is.null(y) && !is.null(x)) {
    self$update(transform = glue("rotate({a} {x} {y})"))
  } else {
    stop("Bad transform rotate specification")
  }
  invisible(self)
})

SVGElement$set("public", "skewX", function(a) {
  self$update(transform = glue("skewX({a})"))
  invisible(self)
})

SVGElement$set("public", "skewY", function(a) {
  self$update(transform = glue("skewY({a})"))
  invisible(self)
})































