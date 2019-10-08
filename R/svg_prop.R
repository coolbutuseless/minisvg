


as_svg_property <- function(x) {
  class(x) <- 'svg_property'
  x
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a function with the given arguments that simply returns the first
# argument value. all args are included for auto-complete during coding
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create_first_arg_func <- function(name, args) {
  args <- unique(c(args, '...'))
  fstring <- glue("function({paste(args, collapse = ', ')}) {{
     value <- find_args(...)[[1]]
     res <- setNames(list(value), name)
     as_svg_property(res)
  }}")

  eval(parse(text = fstring))
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Some magic to create the property helper
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create_inner_inner <- function(value, name) {
  res <- setNames(list(value), name)
  as_svg_property(res)
}

create_inner <- function(prop) {
  res <- lapply(
    prop$values,
    create_inner_inner, prop$name
  )

  res <- setNames(res, prop$values)

  if (!is.null(prop$other)) {
    res$set <- create_first_arg_func(prop$name, prop$other)
  }

  res
}



prop_names <- vapply(svg_properties, function(x) {x$name}, character(1))
inners     <- lapply(svg_properties, create_inner)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' SVG property helper
#'
#' Uses autocomplete to help write some standard propertys
#'
#' @importFrom stats setNames
#' @import glue
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
svg_prop <- setNames(inners, prop_names)




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Convert a CSS 'property' object to a string
#'
#' @param x property object
#' @param ... other arguments
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
as.character.svg_property <- function(x, ...) {
  paste0(names(x), ": ", unname(unlist(x)), ";")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Print a CSS 'property' object
#'
#' @param x property object
#' @param ... other arguments
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print.svg_property <- function(x, ...) {
  cat(as.character(x), "\n", sep = "")
}
















