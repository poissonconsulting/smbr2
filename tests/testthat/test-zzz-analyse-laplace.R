test_that("analyse laplace", {
  embr::set_analysis_mode("check")
  
  # define model in Stan language
  model <- embr::model(mb_code("
data {
  int nAnnual;
  int nObs;
  array[nObs] int Annual;
  array[nObs] int Pairs;
  array[nObs] real Year;
}
parameters {
  vector[nAnnual] bAnnual;
  real log_sAnnual;
  real alpha;
  real beta1;
  real beta2;
  real beta3;
}
transformed parameters {
   real sAnnual;
  real eAnnual;
  sAnnual = exp(log_sAnnual);
  eAnnual = exp(log_sAnnual);
}
model {
  vector[nObs] ePairs;
  log_sAnnual ~ normal(0, 10);
  bAnnual ~ normal(0, sAnnual);
  alpha ~ normal(0, 10);
  beta1 ~ normal(0, 10);
  beta2 ~ normal(0, 10);
  beta3 ~ normal(0, 10);
  for (i in 1:nObs) {
    ePairs[i] = exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 +
                    beta3 * Year[i]^3 + bAnnual[Annual[i]]);
  }
  
  Pairs ~ poisson(ePairs);
}"))
  
  # add R code to calculate derived parameters
  model <- embr::update_model(model, new_expr = "
  for (i in 1:length(Pairs)) {
    prediction[i] <- exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 +
                       beta3 * Year[i]^3 + bAnnual[Annual[i]])
  }
    log_lik <- dpois(Pairs, prediction, log = TRUE)")
  
  # define data types and center year
  model <- embr::update_model(model,
                              select_data = list(
                                "Pairs" = integer(), "Year*" = integer(),
                                Annual = factor()
                              ),
                              derived = "sAnnual",
                              random_effects = list(bAnnual = "Annual"),
                              gen_inits = function(data) {
                                list(log_sAnnual = 20)
                              }
  )
  
  data <- bauw::peregrine
  data$Annual <- factor(data$Year)
  
  seed <- 34
  analysis <- embr::analyse(model, data = data, stan_engine = "cmdstan-laplace",
                            seed = seed, init = 0)
  
  expect_identical(class(analysis), c("cmdstan_laplace_analysis", "cmdstan_analysis", "mb_analysis"))
  expect_true(is.cmdstan_analysis(analysis))
  
  analysis_test <- analysis
  analysis_test$cmdstan_fit <- NULL
  analysis_test$duration <- NULL
  analysis_test$model <- NULL
  expect_snapshot(analysis_test)
  
  expect_identical(pars(analysis, "fixed"), pars(model, "fixed"))
  expect_identical(pars(analysis, "random"), pars(model, "random"))
  expect_identical(pars(analysis, "all"), pars(model, "all"))
  expect_identical(pars(analysis), pars(model))
  expect_identical(pars(analysis, "primary"), pars(model, "primary"))
  expect_identical(pars(analysis, "derived"), pars(model, "derived"))
  expect_identical(pars(analysis, "random"), "bAnnual")
  
  expect_s3_class(as.mcmcr(analysis), "mcmcr")
  
  glance <- glance(analysis)
  expect_snapshot_data(glance)
  
  coef <- coef(analysis, simplify = TRUE)
  expect_snapshot_data(coef)
  expect_s3_class(coef, "mb_analysis_coef")
  
  coef_simp <- coef(analysis, "derived", simplify = TRUE)
  expect_snapshot_data(coef_simp)
  
  coef_all <- coef(analysis, "all", simplify = TRUE)
  expect_snapshot_data(coef_all)
  
  tidy <- tidy(analysis)
  expect_snapshot_data(tidy)
  
  year <- predict(analysis, new_data = "Year")
  expect_snapshot_data(year)
  
  expect_true(all(year$estimate > year$lower))
  expect_true(all(year$estimate < year$upper))
  
  x <- unlist(estimates(analysis))
  names(x) <- NULL
  expect_equal(x, coef$estimate)

  dd <- mcmc_derive_data(analysis, new_data = c("Annual", "Year"), ref_data = TRUE)
  expect_true(mcmcdata::is.mcmc_data(dd))
})