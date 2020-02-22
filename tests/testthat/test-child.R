
my_svg_text <- '
<svg>
  <circle y="1" id="circle1" />
  <rect x="1" id="rect1" />
  <g>
     <rect x="2" />
  </g>
  <circle y="2" />
  <rect x="3" />
  <g><g>
  <rect x="4" id="rect4" />
  </g></g>
  <rect x="5" id="rect5" />
</svg>
'


my_svg <- minisvg::parse_svg_doc(my_svg_text)



test_that("child tracking by tag works", {

  expect_equal(names(my_svg$child), c('circle', 'rect', 'g'))
  expect_length(my_svg$child$circle, 2)
  expect_length(my_svg$child$rect  , 3)
  expect_length(my_svg$child$g     , 2)

  expect_true(my_svg$child$rect[[2]]$attribs$x == 3)

  expect_equal(my_svg$child$g[[2]]$child$g[[1]]$child$rect[[1]]$attribs$id, 'rect4')
})
