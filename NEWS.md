
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
* Added vignetted on `filter-elements`

# minisvg 0.1.0

* Initial release
