#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Create a complete SVG object from an svg pattern
#'
#' @param pattern_list svg_pattern_list object
#' @param width,height the display width of the surrounding SVG wrapper. defualt: 400x400
#' @param ncol number of columns. if NULL, then will use an auto-layout
#' @param ... other arguments ignored
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SVGPatternList_to_svg <- function(pattern_list, width = 400, height = 400, ncol = 2, ...) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Extract pattern ids from the pattern attributes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  pattern_ids <- vapply(pattern_list, function(.x) {.x$attribs$id}, character(1))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Calculate the total size of the SVG canvas to encompass all patterns
  # printed in a square grid
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  n0         <- length(pattern_list)

  if (is.null(ncol)) {
    ncol <- ceiling(sqrt(n0))
  }

  nrow       <- ceiling(n0/ncol)

  svg_width  <- width  * ncol
  svg_height <- height * nrow


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Coordinates of each of the patterns
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  coords <- expand.grid(
    x = (seq(ncol) - 1) * width,
    y = (seq(nrow) - 1) * height
  )

  coords <- coords[seq(n0), ]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Height/Width of each pattern
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  heights <- rep(height, n0)
  widths  <- rep(width , n0)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Combine all the pattern definitions into 'defs' tags
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  defs <- stag$defs(pattern_list)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Collapse all the viewing 'rects' into a single string
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  rects <- glue::glue("
  <rect style='fill: url(#{pattern_ids});' x='{coords$x}' y='{coords$y}' height='{heights}' width='{widths}'></rect>
  ")

  rects <- paste(rects, collapse = "\n")

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create the svg object
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  raw_svg <- svg_doc(
    height = svg_height,
    width  = svg_width,
    defs,
    rects
  )


  raw_svg
}




if (FALSE) {
  library(svgpatternsimple)
  dot          <- create_dot_pattern_minisvg(id = 'one')
  stripe       <- create_stripe_pattern_minisvg(id = 'two')

  pattern_list <- list(dot, stripe)
  width  <- 400
  height <- 400
  ncol   <- 2

  SVGPatternList_to_svg(pattern_list)
}









