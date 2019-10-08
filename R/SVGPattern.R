


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' SVGPattern Class
#'
#' This is a slightly specialized subclass of \code{SVGElement} which has methods
#' to specifically handle SVG \code{<pattern>} nodes
#'
#'
#' @import R6
#' @importFrom glue glue
#' @importFrom utils browseURL
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SVGPattern <- R6::R6Class(
  "SVGPattern", inherit = SVGElement,

  public = list(

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Initialise an SVGPattern object
    #' @param name defaults to 'pattern', but some gradients may also be used here
    #' @param ... Further arguments passed to \code{SVGElement$new()}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initialize = function(..., name = 'pattern') {
      super$initialize(name = name, ...)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Wrap the SVG for this pattern in a full SVG document and return the text
    #' @param height,width dimensions of SVG wrapper around this pattern
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_full_svg = function(width = 400, height = width) {
      stopifnot(!is.null(self$attribs$id))

      full_svg <- SVGDocument$new(width = width, height = height)$
        update(width = NULL, height = NULL)

      full_svg$defs(self)

      full_svg$append(
        stag$rect(
          x      = 0,
          y      = 0,
          height = '100%',
          width  = '100%',
          style  = glue::glue('fill: url(#{self$attribs$id}) #fff;')
        )
      )

      full_svg
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Save the SVG for this pattern in a full SVG document
    #' @param filename filename for output
    #' @param include_declaration Include leading XML declaration. default: TRUE
    #' @param ... Further arguments passed to \code{SVGPattern$as_full_svg()}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    save_full_svg = function(filename, include_declaration = TRUE, ...) {
      svg_string <- self$as_full_svg(...)$as_character(include_declaration = include_declaration)

      writeLines(svg_string, filename)
      invisible(self)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Render this pattern in the context of a complete SVG document
    #' @param viewer viewer.
    #' @param ... Further arguments passed to \code{SVGPattern$save_full_svg()}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    show = function(..., viewer = getOption("viewer", utils::browseURL)) {
      www_dir <- tempfile("viewhtml")
      dir.create(www_dir)
      index_html <- file.path(www_dir, "index.html")
      self$save_full_svg(index_html, ...)

      if (!is.null(viewer)) {
        viewer(index_html)
      } else {
        warning("No viewer available.")
      }
      invisible(index_html)
    }


  )
)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @rdname SVGPattern
#' @usage NULL
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
svg_pattern <- function(...) {
  SVGPattern$new(...)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' knitr/rmarkdown compatibility
#'
#' @param x SVGPattern
#' @param ... other arguments
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
knit_print.SVGPattern <- function(x, ...) {
  full_svg <- x$as_full_svg(...)
  string <- as.character(full_svg, include_declaration = FALSE)
  # Need to be careful when trying to use the string in Rmarkdown.
  # If there are 4(?) leading spaces then the HTML gets turned into a
  # pre-formatted/quoted section.
  string <- gsub("\\s+", " ", string)
  knitr::asis_output(string)
}





if (FALSE) {

  pat <- svg_pattern(id = "one")
  pat
  pat$as_full_svg()
  pat$save_full_svg("crap.svg")

}






