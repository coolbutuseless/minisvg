
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
