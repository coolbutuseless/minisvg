
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a custom func for the given HTML tag name and attributes.
# This custom func will instantiate a new HTMLElement with the given
# name and arguments.
#
# Due to naming standards the following attribute characters will be renamed
#  - '-' will become '_'
#  - ':' will become '..'
#  - 'for' will become 'for.'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create_stag_func <- function(name, attribs) {

  attribs <- c('...', attribs)
  attribs <- gsub("-", "_", attribs)
  attribs <- gsub(":", "..", attribs)
  attribs[attribs == 'in'] <- 'in_'

  func_text <- glue("
function({paste(attribs, collapse = ', ')}) {{
  named_args <- find_args(...)

  args <- c(list(name = '{as.name(name)}'), list(...), named_args)
  do.call(SVGElement$new, args)
}}")

  eval(parse(text = func_text))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a datastructure to help create all the standard html tags.
# Each element in the list is a function to create that particular HTML tag.
# Use 'create_stag_func()' to create the functions so that the attributes exist
# as arguments for use with autocomplete
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
stag <- list()

for (i in seq_along(element_info)) {
  name    <- names(element_info)[i]
  attribs <- element_info[[i]]
  func    <- create_stag_func(name, attribs)
  stag[[name]] <- func
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SVG polygons and polylines actually need a 'points' argument as a single
# string of "x0,y0 x1,y1 x2,y2 ...".  Since this isn't really convenient,
# let the user specify 'xs' and 'ys' vectors of coords which this funciton
# will collapse to the correct format.
#
# If 'xs' is a data.frame then assume that 'x' and 'y' columns contain data.
# If 'xs' is matrix, then assume first 2 columns are 'x' and 'y' data.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
convert_args_to_points <- function(xs, ys) {
  if (is.matrix(xs)) {
    ys <- xs[,2]
    xs <- xs[,1]
  } else if (is.data.frame(xs)) {
    if (!all(c('x', 'y') %in% names(xs))) {
      stop("polygon/polyline data.frame argument must contain 'x' and 'y'")
    }
    ys <- xs[['y']]
    xs <- xs[['x']]
  }
  stopifnot(length(xs) == length(ys))
  stopifnot(length(xs) > 0)
  paste(xs, ys, sep = ",", collapse = " ")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Custom stag function for polygon and polyline to be more R/vector friendly
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
stag$polygon <- function(..., xs, ys, points=NULL) {
  if (is.null(points)) {
    points <- convert_args_to_points(xs, ys)
  }

  SVGElement$new('polygon', points = points, ...)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Custom stag function for polygon and polyline to be more R/vector friendly
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
stag$polyline <- function(..., xs, ys, points) {
  if (is.null(points)) {
    points <- convert_args_to_points(xs, ys)
  }

  SVGElement$new('polyline', points = points, ...)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @name stag
#' @title SVG helper
#' @description SVG builder functions.  Similar in purpose to \code{shiny::tags},
#' but with auto-complete of attribute names as part of the function call.
#'
#' @examples
#' \dontrun{
#' stag$circle(cx = 10, cy = 10, r = 15)
#' # <circle cx="10" cy="10" r="15" />
#' }
#'
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NULL
