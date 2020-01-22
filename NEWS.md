

# minisvg 0.1.5  2020-01-22

* Refactored how CSS is handled. 
    * Can now add multiple external CSS stylesheets with repeated calls to `$add_css_url()`
    * CSS styles which you want to add to the SVG style sheet can be added 
      to any `SVGElement` with `$add_css()`
    * When a top level `<svg>` document is rendered, CSS urls and declarations are 
      accumulated recursive from all child nodes and rendered as a single 
      `<style>` block.
      
# minisvg 0.1.4  2020-01-21

* Added an `SVGFilter` class for prototyping filters. This is just a 
  sub-class of `SVGElement` with some methods to help preview filters.  This 
  is very similar to how the `SVGPattern` class works.
* Updated the vignette on CSS animation to include an example that 
  uses an external CSS style sheet

# minisvg 0.1.3  2020-01-18

* When multiple attributes with the same name are given for an element, then 
  only the last one is kept/used.
* `SVGPattern` objects now have some built-in support for filters

# minisvg 0.1.2  2020-01-12

* For `animate` and related commands, if vectors are passed in as the value
  for a `values` or `keyTimes` argument, then `paste(x, collapse=";")` is applied. 
  This will make some animation setup easier from R since we no longer have 
  to collpse vectors before calling.

# minisvg 0.1.1  2020-01-10

* Added `feBlend` and other filter effects to `stag` and `svg_elem`
* Added vignette on `filter-elements`

# minisvg 0.1.0

* Initial release
