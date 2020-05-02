
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
  "SVGElement", inherit = SVGNode,

  public = list(

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @field name Tag name for this node e.g. "circle"
    #' @field attribs named list of attributes for this node
    #' @field children ordered list of direct child nodes (kept in insertion order)
    #' @field child lists of child nodes indexed by tag name.
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    name     = NULL,
    attribs  = NULL,
    children = NULL,
    child    = NULL,


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
      self$child    <- list()

      self$update(...)

      super$initialize()

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
      # If one of the values for an attribute is an SVGElement, convert it
      # into an ID
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attribs <- lapply(attribs, function(attrib) {
        if (inherits(attrib, 'SVGElement')) {
          id <- attrib$attribs$id %||% "REFERENCE_ELEMENT_HAS_NO_ID"
          # paste0("#", id)
          paste0("url(#", id, ")")
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
      # If duplicate named attributes are given, keep only the last one.
      # Make sure to do this *AFTER* all the 'transform' attributes have been
      # selected as we want to keep all the transforms and concatenate them.
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      dups <- rev(duplicated(rev(names(attribs))))
      if (any(dups)) {
        attribs <- attribs[!dups]
      }

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
      # If colour/fill supplied as attribute.
      # - if colour starts with '#' then just pass it through.
      # - if colour is in 'css_colours' then pass it through
      # - if colour is not in 'grDevices::colours' then pass it through -
      #   and SVG will probably render it as black. Let the user cope with this.
      # - otherwise (it is in grDevices::colors) so convert it to a hexcolour
      #   and give it to SVG
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      colour_attrib_names <- c('fill', 'stroke', 'flood-color', 'lighting-color',
                               'stop-color')
      col_idx <- which(names(attribs) %in% colour_attrib_names)

      if (length(col_idx) > 0L) {
        colour_strings <- unlist(attribs[col_idx])
        pass_through   <- startsWith(colour_strings, '#') |
          colour_strings %in% css_colour_names |
          !(colour_strings %in% r_colour_names)

        col_idx <- col_idx[!pass_through]
        attribs[col_idx] <- rgb(t(col2rgb(colour_strings[!pass_through])), maxColorValue = 255)
      }



      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # all other attribs besides transform overwrite any existing value
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      self$attribs <- modifyList(self$attribs, attribs, keep.null = FALSE)

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # but the 'transform' declaration appends to the current transform.
      # but only take the unique 'transform=<X>' within trans to avoid
      # double-ups within the one call
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if (!is.null(trans) && length(trans) > 0) {
        self$attribs$transform <- paste0(
          c(self$attribs$transform, trans[!duplicated(trans)]),
          collapse = " "
        )
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

      # update $child
      lapply(child_objects, self$update_child_list)

      invisible(self)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Update the list of child nodes by tag name
    #' @param new_elem the element being added
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    update_child_list = function(new_elem) {

      if (!inherits(new_elem, 'SVGNode')) {
        return(invisible(self))
      }

      tagname <- new_elem$name %||% 'unknown'

      if (!tagname %in% names(self$child)) {
        self$child[[tagname]] <- list()
      }

      self$child[[tagname]] <- append(self$child[[tagname]], new_elem)

      invisible(self)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description URebuild the list of child nodes by tag name
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    rebuild_child_list = function() {
      self$child <- list()
      for (elem in self$children) {
        self$update_child_list(elem)
        if (inherits(elem, 'SVGElement')) {
          elem$rebuild_child_list()
        }
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

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Polygon and polyline have built in helpers to convert coords (xs, ys)
      # to the required 'points' string. Defer to 'stag' to create the
      # element
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if (name %in% c('polygon', 'polyline')) {
        new_elem <- stag[[name]](...)
      } else {
        new_elem <- SVGElement$new(name, ...)
      }

      self$append(new_elem)
      invisible(new_elem)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Remove child objects at the given indices
    #'
    #' @param indices indices of the children to remove
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    remove = function(indices) {
      self$children[indices] <- NULL
      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Remove any transform attributes from this node
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    reset_transform = function() {
      self$attribs$transform <- NULL
      invisible(self)
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
            if (inherits(x, "SVGElement") || inherits(x, "SVGLiteral")) {
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
        js_style  <- self$get_js_style()
        c(open, css_style, children, js_style, close)
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
    #' @description test if this element has all of the named attributes
    #'
    #' @param named list of attributes
    #'
    #' @return logical.  Note: if \code{length(attribs) == 0}, this method returns
    #' TRUE
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    has_attribs = function(attribs) {
      if (length(attribs) == 0) {
        return(TRUE)
      }

      if (!all(names(attribs) %in% names(self$attribs))) {
        return(FALSE)
      }

      for (attrib_name in names(attribs)) {
        if (!isTRUE(self$attribs[[attrib_name]] %in% attribs[[attrib_name]])) {
          return(FALSE)
        }
      }

      TRUE
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Find elements which match the given tag names and attributes.
    #'
    #' @param tag character vector of tags to find. default: c()
    #' @param attribs named list of attributes to match. default: list().
    #'        Note that attribute matching is matched using \code{in}
    #'
    #' @examples
    #' \dontrun{
    #' doc$find(tag = c('rect', 'circle'), attribs = list(fill = c('red', 'black')))
    #' }
    #'
    #' @return List of R6 reference objects
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    find = function(tag=c(), attribs=list()) {
      matching_children_of_this_node <- Filter(function(x) {
        (length(tag) == 0 || isTRUE(x$name %in% tag)) &&
        x$has_attribs(attribs)
      }, self$children)

      matching_children_of_sub_nodes <- lapply(self$children, function(x) {
        x$find(tag=tag, attribs=attribs)
      })

      c(matching_children_of_this_node, unlist(matching_children_of_sub_nodes))
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Make a deep copy of this node and its children
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    copy = function() {
      new_elem <- self$clone(deep = TRUE)
      new_elem$rebuild_child_list()
      invisible(new_elem)
    }
  ), # End 'public'


  private = list(
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # When called with `$clone(deep = TRUE)`, the 'deep_clone' function is
    # called for every name/value pair in the object.
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



