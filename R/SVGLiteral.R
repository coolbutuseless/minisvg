

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' A class representing a literal SVG element.
#'
#' @import R6
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SVGLiteral <- R6::R6Class(
  "SVGLiteral", inherit = SVGNode,

  public = list(

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @field x literal contents. Must be coercible to string via 'as.character(x)'
    #' @field name kept only for compatibility with other SVGNode objects. This
    #'        should be set to 'literal'
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    x    = NULL,
    name = "literal",

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Initialize an SVGElement
    #' @param x the literal text to include
    #' @param ... further arguments. Named arguments treated as attributes,
    #'        unnamed arguments treated as child nodes
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initialize = function(x, ...) {
      self$update(x = x)

      super$initialize() # initialize SVGNode

      invisible(self)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Update the SVG Element.
    #'
    #' @details
    #' Named arguments are considered attributes and will overwrite
    #' existing attributes with the same name. Set to NULL to delete the attribute
    #'
    #' Unnamed arguments are appended to the list of child nodes.  These
    #' should be text, other SVGElements or any ojbect that can be represented
    #' as a single text string using "as.character()"
    #'
    #' To print just the attribute name, but without a value, set to NA
    #'
    #' @param x the literal text to include
    #' @param ... attributes and children to set on this node
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    update = function(x, ...) {
      self$x <- x

      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Convert this SVGLiteral
    #' @param ... ignored
    #' @return single character string
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_character_inner = function(...) {
      as.character(self$x)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Convert this SVGLiteral
    #' @param ... ignored
    #' @return single character string
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_character = function(...) {
      as.character(self$x)
    }
  )
)



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @rdname SVGLiteral
#' @usage NULL
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
svg_literal <- function(x) {
  SVGLiteral$new(x = x)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Character representation of SVGLiteral
#'
#' @param x SVGLiteral
#' @param ... other arguments
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
as.character.SVGLiteral <- function(x, ...) {
  x$as_character()
}



if (FALSE) {
  e <- svg_elem('thing')
  e$add_css('#thing {font-size: 55px;}')
  e$add_css_url("eeee")
  f <- svg_elem("asr")
  f$add_css(".bounce {bound: true;}")
  f$append(e)
  f$add_css_url("ffff")
  f$get_css_decls()
  f$get_css_style()
  cat(f$get_css_style())

  d <- svg_doc(f)
  d
}



