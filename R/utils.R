

'%||%' <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}


create_indent <- function(depth) {
  paste0(rep("  ", depth), collapse = "")
}
