test_that("stanc syntax error message is shown when quiet = TRUE", {
  model <- model(code = "parameters { real a } model { a ~ std_normal(); }")
  class(model) <- c("cmdstan_model", class(model))

  expect_error(
    expect_message(load_model(model, quiet = TRUE), "Syntax error"),
    "compilation"
  )
})

test_that("stanc syntax error message is shown when quiet = FALSE", {
  model <- model(code = "parameters { real a } model { a ~ std_normal(); }")
  class(model) <- c("cmdstan_model", class(model))

  expect_error(
    expect_message(load_model(model, quiet = FALSE), "Syntax error"),
    "compilation"
  )
})
