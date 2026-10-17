test_that("as.mcmcr works with a single monitored parameter", {
  skip_if_not_installed("posterior")
  draws <- posterior::as_draws_array(
    array(
      seq_len(20) / 10,
      dim = c(10, 2, 1),
      dimnames = list(iteration = NULL, chain = NULL, variable = "b")
    )
  )
  mcmcr <- as.mcmcr(draws)
  expect_s3_class(mcmcr, "mcmcr")
  expect_identical(names(mcmcr), "b")
  expect_identical(universals::nchains(mcmcr), 2L)
  expect_identical(universals::niters(mcmcr), 10L)
  expect_equal(as.vector(mcmcr$b[1, , 1]), seq_len(10) / 10)
})

test_that("as.mcmcr works with multiple monitored parameters", {
  skip_if_not_installed("posterior")
  draws <- posterior::as_draws_array(
    array(
      rnorm(40),
      dim = c(10, 2, 2),
      dimnames = list(iteration = NULL, chain = NULL, variable = c("a", "b"))
    )
  )
  mcmcr <- as.mcmcr(draws)
  expect_s3_class(mcmcr, "mcmcr")
  expect_identical(names(mcmcr), c("a", "b"))
  expect_identical(universals::nchains(mcmcr), 2L)
})
