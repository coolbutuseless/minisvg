
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Create a list of presentation attributes.
#'
#' This function creates a named list.  It's purpose is mainly as a helper - by
#' having most presentation as named arguments we can use code auto-completion
#' to help remember the 50+ possible attributes.
#'
#' For convenience, any underscores in the names will be replaced by dashes. This
#' is because no sane CSS attributes are named with an underscore, but names
#' with dashes are clunky to write in R.
#'
#' Reference: \url{https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/Presentation}
#'
#' @param alignment_baseline,baseline_shift,clip_path,clip_rule,color,color_interpolation,color_interpolation_filters,color_profile,color_rendering,cursor,direction,display,dominant_baseline,enable_background,fill,fill_opacity,fill_rule,filter,flood_color,flood_opacity,font,font_family,font_size,font_size_adjust,font_stretch,font_style,font_variant,font_weight,glyph_orientation_vertical,image_rendering,kerning,letter_spacing,lighting_color,marker,marker_end,marker_mid,marker_start,mask,opacity,overflow,pointer_events,shape_rendering,stop_color,stop_opacity,stroke,stroke_dasharray,stroke_dashoffset,stroke_linecap,stroke_linejoin,stroke_miterlimit,stroke_opacity,stroke_width,text_anchor,text_decoration,text_rendering,unicode_bidi,visibility,word_spacing,writing_mode named parameters (included to help when using auto-complete)
#' @param ... other named parameters
#'
#' @return a list of presentation attributes
#'
#' @importFrom stats setNames
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pres <- function(
  ...,
  alignment_baseline, baseline_shift,
  clip_path, clip_rule,
  color, color_interpolation, color_interpolation_filters, color_profile, color_rendering,
  cursor,
  direction,
  display,
  dominant_baseline,
  enable_background,
  fill, fill_opacity, fill_rule,
  filter,
  flood_color,
  flood_opacity,
  font, font_family, font_size, font_size_adjust, font_stretch, font_style, font_variant, font_weight,
  glyph_orientation_vertical, image_rendering, kerning, letter_spacing,
  lighting_color,
  marker, marker_end, marker_mid, marker_start,
  mask,
  opacity,
  overflow,
  pointer_events,
  shape_rendering,
  stop_color, stop_opacity,
  stroke, stroke_dasharray, stroke_dashoffset, stroke_linecap, stroke_linejoin, stroke_miterlimit, stroke_opacity, stroke_width,
  text_anchor, text_decoration, text_rendering, unicode_bidi, visibility,
  word_spacing, writing_mode
  ) {

  varargs <- find_args(...)
  attr_names <- names(varargs)

  if (is.null(attr_names) || any(attr_names == '') || any(is.na(attr_names))) {
    stop("pres(): All args must be named: ", deparse(varargs))
  }

  attr_names <- gsub('colour', 'color', attr_names)
  attr_names <- gsub("_"     , "-"    , attr_names)

  setNames(varargs, attr_names)
}



if (FALSE) {
  pres(fill_opacity = 0.3, colour = "red", fill = 'black')
}




