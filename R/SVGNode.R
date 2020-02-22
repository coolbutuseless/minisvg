

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' A class representing a single SVG element.
#'
#' @import R6
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SVGNode <- R6::R6Class(
  "SVGNode",

  public = list(

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @field css_decls character vector of css declaration text for this node
    #' @field css_urls character vector of css urls for this node
    #' @field js_code character vector of javascript code for this node
    #' @field js_urls character vector of javascript urls for this node
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    css_decls = NULL,
    css_urls  = NULL,
    js_code   = NULL,
    js_urls   = NULL,


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Initialize an SVGNode
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initialize = function() {

      self$css_urls  <- c()
      self$css_decls <- c()
      self$js_code   <- c()
      self$js_urls   <- c()

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
      stop("Method must be set in derived class.")
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Add a URL to a CSS style sheet
    #' @param css_url URL to style sheet. e.g. \code{$add_css_url("css/local.css")}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    add_css_url = function(css_url) {
      self$css_urls <- c(self$css_urls, css_url)
      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Add a CSS declaration for this element.
    #' @param css_decl CSS string, or object which can be coerced to character.
    #'        e.g. \code{$add_dec("#thing {font-size: 27px}")}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    add_css = function(css_decl) {
      self$css_decls <- c(self$css_decls, css_decl)
      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Add javascript code for this element
    #' @param js_code character string containing javascript code.
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    add_js_code = function(js_code) {
      self$js_code <- c(self$js_code, js_code)
      invisible(self)
    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Add a javaxcript URL to load within the SVG
    #' @param js_url URL to javascript code. e.g. \code{$add_js_url("example.org/eg.js")}
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    add_js_url = function(js_url) {
      self$js_urls <- c(self$js_urls, js_url)
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
    #' @description Create a character vector of JS code for this node and
    #'              all child nodes.
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    get_js_code = function() {
      js_code <- lapply(self$children, function(x) {
        if (inherits(x, "SVGElement")) {
          x$get_js_code()
        } else {
          NULL
        }})

      js_code <- unlist(js_code)
      js_code <- as.character(js_code)
      c(self$js_code, js_code)
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Create a vector of external JS urls
    #' @details this includes all CSS URLs for all child elements
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    get_js_urls = function() {
      urls <- lapply(self$children, function(x) {
        if (inherits(x, "SVGElement")) {
          x$get_js_urls()
        } else {
          NULL
        }})
      urls <- unlist(urls)
      urls <- as.character(urls)
      c(self$js_urls, urls)
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
        "<style type='text/css'>\n<![CDATA[",
        glue::glue("@import url({unique(urls)});"),
        paste(unique(decls), collapse = "\n"),
        "]]>\n</style>"
      ), collapse = "\n")
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Create a complete CSS style tag using the declarations
    #'              and URLs of the current element, and all child elements.
    #' @return character string
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    get_js_style = function() {
      code <- self$get_js_code()
      urls <- self$get_js_urls()

      if (length(code) == 0 && length(urls) == 0) {
        return(NULL)
      }

      paste0(c(
        glue::glue("<script xlink:href='{unique(urls)}'></script>"),
        "<script language='javascript'>\n<![CDATA[",
        paste(unique(code), collapse = "\n"),
        "]]>\n</script>"
      ), collapse = "\n")
    },




    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description  Recursively convert this SVGElement and children to text
    #' @return single character string
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_character_inner = function() {
      stop("Method must be set in derived class.")
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Recursively convert this SVGElement and children to text
    #' @return single character string
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    as_character = function() {
      stop("Method must be set in derived class.")
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
    },


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Find elements which match the given tags
    #'
    #' @param tags character vector of tags to accept
    #'
    #' @return minisvg objects which inherit from SVGNode will return NULL
    #'         unless this method is overridden.
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    find = function(tags) {
      NULL
    }
  )
)



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Character representation of SVGNode
#'
#' @param x SVGNode
#' @param ... other arguments
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
as.character.SVGNode <- function(x, ...) {
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



