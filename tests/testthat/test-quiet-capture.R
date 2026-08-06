test_that("quiet_capture muffles messages and warnings on success", {
  expect_silent(quiet_capture({
    message("Compiling Stan program...")
    warning("Chain 1 finished unexpectedly!")
    invisible(1)
  }))
})

test_that("quiet_capture replays muffled messages when an error occurs", {
  expect_error(
    expect_message(
      quiet_capture({
        message("informative context")
        stop("boom")
      }),
      "informative context"
    ),
    "boom"
  )
})

test_that("quiet_capture replays muffled warnings when an error occurs", {
  expect_error(
    expect_warning(
      quiet_capture({
        warning("chains finished unexpectedly")
        stop("boom")
      }),
      "chains finished unexpectedly"
    ),
    "boom"
  )
})
