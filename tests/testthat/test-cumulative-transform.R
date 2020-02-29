

test_that("transforms are cumulative", {

  heart_shadow <- stag$g(
    fill = 'grey',
    svg_prop$transform$rotate(-10, 50, 100),
    svg_prop$transform$translate(-36, 45.5),
    svg_prop$transform$skewX(40),
    svg_prop$transform$scale(1, 0.5)
  )

  expect_equal(
    heart_shadow$attribs$transform,
    "rotate(-10 50 100) translate(-36 45.5) skewX(40) scale(1 0.5)"
  )


})
