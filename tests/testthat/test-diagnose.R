test_that("diagnose.cmdstan_mcmc_analysis works", {
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
}"), select_data = list(
  "Pairs" = integer(), "Year*" = integer(),
  Annual = factor()
))

  data <- bauw::peregrine
  data$Annual <- factor(data$Year)
  
  seed <- 34
  analysis_mcmc <- embr::analyse(model, data = data, stan_engine = "cmdstan-mcmc", seed = seed)
  analysis_pathfinder <- embr::analyse(model, data = data, stan_engine = "cmdstan-pathfinder", seed = seed)
  analysis_variational <- embr::analyse(model, data = data, stan_engine = "cmdstan-variational", seed = seed)

  diagnostics <- diagnose(analysis_mcmc)
  expect_s3_class(diagnostics, "cmdstan_diagnostics")
  expect_identical(names(diagnostics), c("status", "stdout", "stderr", "timeout"))

  diagnostics <- diagnose(analysis_pathfinder)
  expect_s3_class(diagnostics, "cmdstan_diagnostics")
  expect_identical(names(diagnostics), c("status", "stdout", "stderr", "timeout"))
  
  diagnostics <- diagnose(analysis_variational)
  expect_s3_class(diagnostics, "cmdstan_diagnostics")
  expect_identical(names(diagnostics), c("status", "stdout", "stderr", "timeout"))
  
})