


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' SVGDocument Class
#'
#' This is a specialized subclass of \code{SVGElement} containing some methods specific
#' to the top level SVG node.
#'
#'
#' @import R6
#' @importFrom glue glue
#' @importFrom utils browseURL
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SVGDocument <- R6::R6Class(
  "SVGDocument", inherit = SVGElement,

  public = list(

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @field width,height dimensions of document
    #' @field css_url External CSS file link. Default: NULL
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    width   = NULL,
    height  = NULL,
    css_url = NULL,

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Initialise a new SVG document
    #' @param width,height SVG dimensions. default: 400x400
    #' @param viewBox if NULL, then set to "0 0 {width} {height}"
    #' @param preserveAspectRatio,xmlns,xmlns_xlink standard SVG attributes
    #' @param ... further arguments. Named arguments treated as attributes,
    #'        unnamed arguments treated as child nodes
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initialize = function(..., width = 400, height = 400, viewBox = NULL,
                          preserveAspectRatio = NULL,
                          xmlns = 'http://www.w3.org/2000/svg',
                          xmlns_xlink = 'http://www.w3.org/1999/xlink') {

      self$width  <- width
      self$height <- height
      if (is.null(viewBox)) {
        viewBox <- glue("0 0 {width} {height}")
      }

      super$initialize(
        name        = 'svg',
        width       = width,
        height      = height,
        viewBox     = viewBox,
        xmlns       = xmlns,
        xmlns_xlink = xmlns_xlink,
        ...)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Save a complete HTML document containing this SVG document
    #' @param filename HTML filename
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    save_html = function(filename) {
      html <- paste('<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>

</head>
<body style="background-color:white;">
',
                    self$as_character(),
                    '\n</body>
</html>')

      writeLines(html, filename)

    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Render the SVG in the current viewer.
    #' @details Has only been tested with MacOS and Rstudio
    #' @param viewer which viewer to use?
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    show = function(viewer = getOption("viewer", utils::browseURL)) {
        www_dir <- tempfile("viewhtml")
        dir.create(www_dir)
        index_html <- file.path(www_dir, "index.html")
        self$save_html(index_html)

        if (!is.null(viewer)) {
          viewer(index_html)
        } else {
          warning("No viewer available.")
        }
        invisible(index_html)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Use the supplied string as the inline CSS for this document
    #' @param css string containing CSS
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    inline_css = function(css) {
      style <- glue::glue("<style type='text/css'><![CDATA[
      {css}
    ]]>
    </style>")

      self$defs(style)

      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Print the SVGDocument object
    #' @param include_declaration Include the XML declaration? default: TRUE
    #' @param ... other arguments passed to \code{$as_character()}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    print = function(include_declaration = TRUE, ...) {
      cat(self$as_character(include_declaration = include_declaration, ...))
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Set the URL to an external CSS style sheet
    #' @param css_url URL to style sheet. e.g. \code{css/local.css}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    external_css_url = function(css_url) {
      self$css_url <- css_url
      invisible(self)
    }


  )
)



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @rdname SVGDocument
#' @usage NULL
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
svg_doc <- function(..., width = 400, height = 400, viewBox = NULL,
                    preserveAspectRatio = NULL,
                    xmlns               = 'http://www.w3.org/2000/svg',
                    xmlns_xlink         = 'http://www.w3.org/1999/xlink') {

  SVGDocument$new(..., width = width, height = height, viewBox = viewBox,
                  preserveAspectRatio = preserveAspectRatio,
                  xmlns = xmlns,
                  xmlns_xlink = xmlns_xlink)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Character representation of SVGDocument
#'
#' @param x SVGDocument
#' @param include_declaration Include the SVG declaration at the top? Default: TRUE
#' @param ... other arguments
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
as.character.SVGDocument <- function(x, include_declaration = TRUE, ...) {
  x$as_character(include_declaration = include_declaration, ...)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' knitr/rmarkdown compatibility
#'
#' @param x SVGDocument
#' @param ... other arguments
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
knit_print.SVGDocument <- function(x, ...) {
  string <- as.character(x, include_declaration = FALSE)
  # Need to be careful when trying to use the string in Rmarkdown.
  # If there are 4(?) leading spaces then the HTML gets turned into a
  # pre-formatted/quoted section.
  string <- gsub("\\s+", " ", string)
  knitr::asis_output(string)
}




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' SVG shower
#'
#' @param svg SVG text or object
#' @param viewer viewer
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
show_svg <- function(svg, viewer = getOption("viewer", utils::browseURL)) {
  www_dir <- tempfile("viewhtml")
  dir.create(www_dir)
  index_html <- file.path(www_dir, "index.html")
  writeLines(as.character(svg), index_html)

  if (!is.null(viewer)) {
    viewer(index_html)
  } else {
    warning("No viewer available.")
  }
  invisible(index_html)
}



if (FALSE) {
  s <- SVGDocument$new(width = 200, height = 200)
  rect <- s$rect(x = 10, y = 10, width = 100, height = 100)
  rect$animate(attributeType = 'XML', attributeName = 'x', from = -100, to = 120, dur = 10, repeatCount = 'indefinite')
  s

  s$save("working/crap.svg")
}



if (FALSE) {
  # https://svgjs.com/docs/2.7/tutorials/
  library(minicss)

  s <- SVGDocument$new(width = 400, height = 400)
  # circle <- s$add('circle', cx = 60, cy = 60, r= 30)


  circle <- s$circle(cx = 60, cy = 60, r= 30)
  circle$update(style = css_style(fill = "#ff9", stroke = 'gray', stroke_width = 10))
  circle$add('animate', attributeName = 'fill', begin = 2, dur = 4, from = '#ff9', to = 'red', fill = 'freeze')

  s$show()
}


if (FALSE) {
  library(minicss)

  s <- SVGDocument$new(width = 400, height = 400)
  defs <- s$defs()
  pattern <- defs$pattern(id = 'tile', x=0, y=0, width = "20%", height = "20%", patternUnits = "objectBoundingBox")
  pattern$path(d = "M 0 0 Q 5 20 10 10 T20 20", pres(stroke = 'black', fill = 'none'))
  pattern$path(d = "M 0 0 h 20 v 20 h -20 z"  , pres(stroke = 'gray', fill = 'none'))

  s$rect(x = 20, y = 20, width = "100", height = "100", fill = pattern, style = css_style(stroke = 'black'))
  s
  s$show()
}


if (FALSE) {
  # https://developer.mozilla.org/en-US/docs/Web/SVG/Element/radialGradient
  s <- SVGDocument$new(width = 100, height = 100)
  defs <- s$defs()
  rgrad <- defs$radialGradient(id = "myGradient")
  rgrad$stop(offset = "10%", stop_color = 'gold')
  rgrad$stop(offset = "95%", stop_color = 'red')

  s$circle(cx = 50, cy = 50, r = 40, fill = rgrad)
  s

  s$show()
}






