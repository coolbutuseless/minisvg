

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Recursively parse an XML2 node tree into a `minixml` document
#'
#' This uses 'xml2' package to do the parsing.
#'
#' @param xml2_node root node of a document or an element node
#' @param as_document parse the root node as a document node. Default: TRUE
#' @param as_pattern  parse the root node as a pattern node. Default: FALSE
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parse_inner <- function(xml2_node, as_document = TRUE, as_pattern=FALSE) {
  name     <- xml2::xml_name(xml2_node)
  attrs    <- xml2::xml_attrs(xml2_node)
  children <- xml2::xml_contents(xml2_node)

  if (as_document) {
    if (name != 'svg') {
      stop("This doesn't appear to be an SVG document. Perhaps try 'parse_svg_elem()' instead", call. = FALSE)
    }
    doc <- svg_doc()
  } else if (as_pattern) {
    if (name != 'pattern') {
      stop("This doesn't appear to be an SVG pattern. Perhaps try 'parse_svg_elem()' instead", call. = FALSE)
    }
    doc <- SVGPattern$new()
  } else {
    doc <- svg_elem(name = name)
  }
  do.call(doc$update, as.list(attrs))

  child_nodes <- lapply(children, function(x) {
    if (xml2::xml_name(x) == 'text' && length(xml2::xml_attrs(x)) == 0) {
      as.character(x)
    } else {
      parse_inner(x, as_document = FALSE, as_pattern=FALSE)
    }
  })
  do.call(doc$append, child_nodes)

  doc
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Parse SVG text or file into an SVGDocument or SVGElement
#'
#' @param x,encoding,...,as_html,options options passed to \code{xml2::read_xml()}
#' @param as_pattern  parse the root node as a pattern node. Default: FALSE
#'
#' @return XMLDocument or XMLElement
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parse_svg_doc <- function(x, encoding='', ..., as_html = FALSE, options = 'NOBLANKS') {

  if (!requireNamespace("xml2", quietly = TRUE)) {
    stop("parse_svg_doc(): need 'xml2' installed to read XML", call. = FALSE)
  }

  xml2_node <- xml2::read_xml(x=x, encoding=encoding, ..., as_html=as_html, options=options)

  parse_inner(xml2_node, as_document = TRUE, as_pattern = FALSE)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @rdname parse_svg_doc
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
parse_svg_elem <- function(x, encoding='', ..., as_html = FALSE, options = 'NOBLANKS', as_pattern = FALSE) {

  if (!requireNamespace("xml2", quietly = TRUE)) {
    stop("parse_svg_elem(): need 'xml2' installed to read XML", call. = FALSE)
  }

  xml2_node <- xml2::read_xml(x=x, encoding=encoding, ..., as_html=as_html, options=options)

  parse_inner(xml2_node, as_document = FALSE, as_pattern = as_pattern)
}
