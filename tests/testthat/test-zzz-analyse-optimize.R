test_that("analyse optimize", {
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
  analysis <- embr::analyse(model, data = data, stan_engine = "cmdstan-optimize", seed = seed)
  
  expect_identical(class(analysis), c("cmdstan_optimize_analysis", "cmdstan_analysis", "mb_analysis"))
  expect_true(is.cmdstan_analysis(analysis))
  
  summary <- analysis$cmdstan_fit$summary()
  expect_s3_class(summary, "tbl")
})