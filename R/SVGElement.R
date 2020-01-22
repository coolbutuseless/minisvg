
if (FALSE) {

  s <- SVGElement$new('a')
  d <- s$defs(a = 1)
  d
  s



  s <- SVGElement$new('a')
  d <- SVGElement$new('defs')
  s$add(d)
  s

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' A class representing a single SVG element.
#'
#' @import R6
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SVGElement <- R6::R6Class(
  "SVGElement",

  public = list(

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @field name Tag name for this node e.g. "circle"
    #' @field attribs named list of attributes for this node
    #' @field children list of direct child nodes
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    name     = NULL,
    attribs  = NULL,
    children = NULL,

    css_decls = NULL,
    css_urls  = NULL,


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Initialize an SVGElement
    #' @param name node name e.g. "circle"
    #' @param ... further arguments. Named arguments treated as attributes,
    #'        unnamed arguments treated as child nodes
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initialize = function(name, ...) {
      self$name     <- name
      self$attribs  <- list()
      self$children <- list()

      self$css_urls  <- c()
      self$css_decls <- c()

      self$update(...)

      class(self) <- unique(c(class(self), "shiny.tag"))

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
    #' @param ... attributes and children to set on this node
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    update = function(...) {
      varargs <- list(...)

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # If caller is using any of the attribute helpers e.g. 'pres()' to
      # help set attributes, then these results will be a list nested within
      # '...' argument. So use unlist() to carefully remove one layer of listing
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      is_list_element <- vapply(varargs, is.list, logical(1))
      if (any(is_list_element)) {
        varargs <- unlist(varargs, recursive = FALSE, use.names = TRUE)
      }

      is_list_element <- vapply(varargs, is.list, logical(1))
      if (any(is_list_element)) {
        stop("SVGElement$update(): does not handle nested lists")
      }



      vararg_names <- names(varargs)
      if (is.null(vararg_names)) {
        vararg_names <- character(length = length(varargs))
      }
      has_name   <- nzchar(vararg_names)

      children <- varargs[!has_name]
      attribs  <- varargs[ has_name]

      do.call(self$append, children)

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # If duplicate named attributes are given, keep only the last one
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      dups <- rev(duplicated(rev(names(attribs))))
      if (any(dups)) {
        attribs <- attribs[!dups]
      }

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # If one of the values for an attribute is an SVGElement, convert it
      # into an ID
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attribs <- lapply(attribs, function(attrib) {
        if (inherits(attrib, 'SVGElement')) {
          id <- attrib$attribs$id %||% "REFERENCE_ELEMENT_HAS_NO_ID"
          # paste0("#", id)
          paste0("url('#", id, "')")
        } else {
          attrib
        }})

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Correct some make names with colons and dashes easier to pass in
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attrib_names <- names(attribs)
      attrib_names[attrib_names == 'in_'] <- 'in'
      attrib_names <- gsub("xmlns_xlink", "xmlns:xlink", attrib_names)
      attrib_names <- gsub("xlink_href" , "xlink:href" , attrib_names)
      attrib_names <- gsub("_"          , "-"          , attrib_names)
      attrib_names <- gsub("colour"     , "color"      , attrib_names)
      names(attribs) <- attrib_names


      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # pull out any 'transform' changes and handle separately
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      trans <- attribs[names(attribs) == 'transform']
      attribs[names(attribs) == 'transform'] <- NULL


      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # If element is animate, animateColor, animateMotion, animateTransform
      # and the user passes in a vector for a 'values' or 'keyTimes' attribute, then
      # collapse it to a single string value.
      # For 'feColorMatrix' values is collapsed with a space separator.
      # Ref: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/values
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      if (self$name %in% c('animate', 'animateMotion', 'animateColor', 'animateTransform')) {
        if ('values' %in% names(attribs)) {
          idx <- which(names(attribs) == 'values')
          if (length(attribs[[idx]] > 1)) {
            attribs[[idx]] <- paste(attribs[[idx]], collapse = ";")
          }
        }
        if ('keyTimes' %in% names(attribs)) {
          idx <- which(names(attribs) == 'keyTimes')
          if (length(attribs[[idx]] > 1)) {
            attribs[[idx]] <- paste(attribs[[idx]], collapse = ";")
          }
        }
      }


      if (self$name %in% c('feColorMatrix')) {
        if ('values' %in% names(attribs)) {
          idx <- which(names(attribs) == 'values')
          if (length(attribs[[idx]] > 1)) {
            attribs[[idx]] <- paste(attribs[[idx]], collapse = " ")
          }
        }
      }


      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # all other attribs besides transform overwrite any existing value
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      self$attribs <- modifyList(self$attribs, attribs, keep.null = FALSE)

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # but the 'transform' declaration appends to the current transform
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if (!is.null(trans) && length(trans) > 0) {
        self$attribs$transform <- paste0(c(self$attribs$transform, trans), collapse = " ")
      }

      invisible(self)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Append child nodes at the specified position.
    #' @param position by default at the end of the list of children nodes
    #'        but 'position' argument can be used to set location by index
    #' @param ... child nodes
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    append = function(..., position = NULL) {
      child_objects <- list(...)

      child_objects <- Filter(Negate(is.null), child_objects)

      if (is.null(position)) {
        self$children <- append(self$children, child_objects)
      } else {
        self$children <- append(self$children, child_objects, after = position - 1)
      }

      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Simultaneous create an SVG element and add it as a child node
    #'
    #' @param name name of node to create
    #' @param ... attributes and children of this newly created node
    #' @return In contrast to most other methods, \code{$add()} returns
    #' the newly created element, \emph{not} the document
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    add = function(name, ...) {
      if (!is.character(name)) {
        stop("SVGElement$add(): 'name' must be a character string")
      }
      new_elem <- SVGElement$new(name, ...)
      self$append(new_elem)
      invisible(new_elem)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Remove child objects at the given indicies
    #'
    #' @param indicies indicies of the children to remove
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    remove = function(indicies) {
      self$children[indices] <- NULL
      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Remove any transform attributes from this node
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    reset_transform = function() {
      self$attribs$transform <- NULL
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Add a URL to a CSS style sheet
    #' @param css_url URL to style sheet. e.g. \code{"$add_css_url("css/local.css")}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    add_css_url = function(css_url) {
      self$css_urls <- c(self$css_urls, css_url)
      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Add a CSS declaration for this element.
    #' @param css_dec CSS string, or object which can be coerced to character.
    #'        e.g. \code{$add_dec("#thing {font-size: 27px}")}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    add_css = function(css_decl) {
      self$css_decls <- c(self$css_decls, css_decl)
      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Create a CSS declaration string for inclusion in the
    #'              character output for this element.
    #' @details this includes all css for all child elements
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    get_css_decls = function() {
      decls <- lapply(self$children, function(x) {
        if (inherits(x, "SVGElement")) {
          x$get_css_decls()
        } else {
          NULL
        }})

      decls <- unlist(decls)
      decls <- as.character(decls)
      c(self$css_decls, decls)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Create a vector or urls for CSS inclustion
    #' @details this includes all CSS URLs for all child elements
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    get_css_urls = function() {
      urls <- lapply(self$children, function(x) {
        if (inherits(x, "SVGElement")) {
          x$get_css_urls()
        } else {
          NULL
        }})
      urls <- unlist(urls)
      urls <- as.character(urls)
      c(self$css_urls, urls)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Create a complete CSS <style> tag using the declarations
    #'              and URLs of the current element, and all child elements.
    #' @return character string
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    get_css_style = function() {
      decls <- self$get_css_decls()
      urls  <- self$get_css_urls()

      if (length(decls) == 0 && length(urls) == 0) {
        return(NULL)
      }

      paste0(c(
        "<style type='text/css'><![CDATA[",
        glue::glue("@import url({urls});"),
        paste(decls, collapse = "\n"),
        "]]>\n</style>"
      ), collapse = "\n")


    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description  Recursively convert this SVGElement and children to text
    #' @param ... ignored
    #' @param depth recursion depth
    #' @return single character string
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_character_inner = function(..., depth = 0) {
      indent1   <- create_indent(depth)
      indent2   <- create_indent(depth + 1)

      # na_attribs    <- Filter(       is.na , self$attribs)
      # value_attribs <- Filter(Negate(is.na), self$attribs)
      # TODO FIXME
      value_attribs <- self$attribs
      na_attribs    <- c()

      if (length(na_attribs) > 0) {
        na_attribs  <- names(na_attribs)
        na_attribs  <- paste(na_attribs, sep = " ")
        na_attribs  <- paste0(" ", na_attribs)
      } else {
        na_attribs <- NULL
      }


      if (length(value_attribs) > 0) {

        # Special handling for 'keyTimes' and 'values' attributes, which will
        # collapse a vector into a semi-colon-separated character string
        for (ii in seq_along(value_attribs)) {
          if (names(value_attribs)[ii] %in% c('values', 'keyTimes')) {
            value_attribs[[ii]] <- paste(value_attribs[[ii]], collapse = ";")
          } else if (names(value_attribs)[ii] %in% c('from', 'to')) {
            value_attribs[[ii]] <- paste(value_attribs[[ii]], collapse = " ")
          }
        }

        value_attribs <- paste(names(value_attribs),
                               paste0('"', value_attribs, '"'),
                               sep = "=", collapse = " ")
        value_attribs <- paste0(" ", value_attribs)
      } else {
        value_attribs <- NULL
      }

      attribs <- paste0(c(value_attribs, na_attribs), sep = "")
      open    <- glue::glue("{indent1}<{self$name}{attribs}>")
      close   <- glue::glue("{indent1}</{self$name}>")

      if (length(self$children) > 0) {
        children <- lapply(
          self$children,
          function(x, depth) {
            if (inherits(x, "SVGElement")) {
              x$as_character_inner(depth = depth)
            } else {
              paste0(indent2, x)
            }
          }
          , depth = depth + 1)
        children <- unlist(children, use.names = FALSE)
      } else {
        children = NULL
      }

      if (is.null(children) || length(children) == 0) {
        open  <- glue::glue("{indent1}<{self$name}{attribs} />")
        close <- NULL
      }



      if (depth == 0 && 'SVGDocument' %in% class(self)) {
        css_style <- self$get_css_style()
        c(open, css_style, children, close)
      } else {
        c(open, children, close)
      }
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Recursively convert this SVGElement and children to text
    #' @param ... ignored
    #' @param depth recursion depth. default: 0
    #' @param include_declaration Include the leading XML declaration? default: FALSE
    #' @return single character string
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_character = function(..., depth = 0, include_declaration = FALSE) {
      svg_string <- paste0(self$as_character_inner(depth = depth), collapse = "\n")

      if (include_declaration) {
        svg_string <- paste('<?xml version="1.0" encoding="UTF-8"?>', svg_string, sep = "\n")

      }

      attr(svg_string, "html") <- TRUE
      class(svg_string) <- unique(c("html", "character", class(svg_string)))
      svg_string
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Print the SVG string to the terminal
    #' @param ... Extra arguments passed to \code{SVGElement$as_character()}
    #' @param include_declaration Include the leading XML declaration? default: FALSE
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    print = function(include_declaration = FALSE, ...) {
      cat(self$as_character(include_declaration = include_declaration, ...))
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Save the text representation of this node and its children
    #' @param filename filename
    #' @param include_declaration Include the leading XML declaration? default: FALSE
    #' @param ... Extra arguments passed to \code{SVGElement$as_character()}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    save = function(filename, include_declaration = FALSE, ...) {
      svg_string <- self$as_character(include_declaration = include_declaration)

      writeLines(svg_string, filename)
      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Make a deep copy of this node and its children
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    copy = function() {
      self$clone(deep = TRUE)
    }
  ), # End 'public'


  private = list(
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # When called with `$clone(deep = TRUE)`, the 'deep_clone' function is
    # called for every name/value pari in the object.
    # Need special handling for:
    #   - 'children' is a list of R6 objects
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    deep_clone = function(name, value) {
      if (name %in% c('children')) {
        lapply(value, function(x) {if (inherits(x, "R6")) x$clone(deep = TRUE) else x})
      } else {
        value
      }
    }
  )
)



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @rdname SVGElement
#' @usage NULL
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
svg_elem <- function(name, ...) {
  SVGElement$new(name, ...)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Character representation of SVGElement
#'
#' @param x SVGElement
#' @param ... other arguments
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
as.character.SVGElement <- function(x, ...) {
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



