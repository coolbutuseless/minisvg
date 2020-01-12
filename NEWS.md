
# minisvg 0.1.2  20200112

* For `animate` and related commands, if vectors are passed in as the value
  for a `values` or `keyTimes` argument, then `paste(x, collapse=";")` is applied. 
  This will make some animation setup easier from R since we no longer have 
  to collpse vectors before calling.

# minisvg 0.1.1  20200110

* Added `feBlend` and other filter effects to `stag` and `svg_elem`
* Added vignetted on `filter-elements`

# minisvg 0.1.0

* Initial release
