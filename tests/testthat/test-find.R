

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
</svg>
'


my_svg <- minisvg::parse_svg_doc(my_svg_text)


test_that("find works", {
  res <- my_svg$find(tag = "rect")
  expect_type(res, 'list')
  expect_length(res, 4)

  res <- my_svg$find(attribs = list(id = "circle1"))
  expect_type(res, 'list')
  expect_length(res, 1)

  res <- my_svg$find(attribs = list(id = "ugh0"))
  expect_identical(res, list())

  res <- my_svg$find(attribs = list(id = c("circle1", 'rect4')))
  expect_type(res, 'list')
  expect_length(res, 2)

  res <- my_svg$find(tag = 'rect', attribs = list(id = c("circle1", 'rect4')))
  expect_type(res, 'list')
  expect_length(res, 1)
  expect_identical(res[[1]]$attribs$id, 'rect4')
})
