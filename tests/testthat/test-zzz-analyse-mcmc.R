test_that("analyse", {
  embr::set_analysis_mode("check")

  # define model in Stan language
  model <- embr::model(mb_code(
    "
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
}"
  ))

  # add R code to calculate derived parameters
  model <- embr::update_model(
    model,
    new_expr = "
  for (i in 1:length(Pairs)) {
    prediction[i] <- exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 +
                       beta3 * Year[i]^3 + bAnnual[Annual[i]])
  }
    log_lik <- dpois(Pairs, prediction, log = TRUE)"
  )

  # define data types and center year
  model <- embr::update_model(
    model,
    select_data = list(
      "Pairs" = integer(),
      "Year*" = integer(),
      Annual = factor()
    ),
    derived = "sAnnual",
    random_effects = list(bAnnual = "Annual"),
    gen_inits = function(data) {
      list(log_sAnnual = 20)
    }
  )

  expect_identical(
    pars(model, "fixed"),
    c("alpha", "beta1", "beta2", "beta3", "log_sAnnual")
  )
  expect_identical(pars(model, "random"), "bAnnual")
  expect_identical(
    pars(model, "primary"),
    c("alpha", "bAnnual", "beta1", "beta2", "beta3", "log_sAnnual")
  )
  expect_identical(pars(model, "derived"), "sAnnual")

  expect_identical(
    pars(model, "all"),
    c("alpha", "bAnnual", "beta1", "beta2", "beta3", "log_sAnnual", "sAnnual")
  )

  expect_identical(
    pars(code(model), "all"),
    c(
      "alpha",
      "bAnnual",
      "beta1",
      "beta2",
      "beta3",
      "eAnnual",
      "log_sAnnual",
      "sAnnual"
    )
  )

  expect_identical(pars(model), pars(model, "all"))

  data <- bauw::peregrine
  data$Annual <- factor(data$Year)

  seed <- 34
  analysis <- embr::analyse(
    model,
    data = data,
    stan_engine = "cmdstan-mcmc",
    seed = seed
  )

  expect_identical(
    class(analysis),
    c("cmdstan_mcmc_analysis", "cmdstan_analysis", "mb_analysis")
  )
  expect_true(is.cmdstan_analysis(analysis))

  expect_identical(universals::niters(analysis), 500L)
  expect_identical(universals::nchains(analysis), 2L)
  expect_identical(universals::nsims(analysis), 1000L)
  expect_identical(embr::ngens(analysis), 2000L)

  expect_identical(niters(analysis), 500L)
  expect_identical(ngens(analysis), 2000L)

  expect_identical(pars(analysis, "fixed"), pars(model, "fixed"))
  expect_identical(pars(analysis, "random"), pars(model, "random"))
  expect_identical(pars(analysis, "all"), pars(model, "all"))
  expect_identical(pars(analysis), pars(model))
  expect_identical(pars(analysis, "primary"), pars(model, "primary"))
  expect_identical(pars(analysis, "derived"), pars(model, "derived"))
  expect_identical(pars(analysis, "random"), "bAnnual")

  expect_s3_class(as.mcmcr(analysis), "mcmcr")

  expect_identical(universals::niters(analysis), 500L)
  expect_identical(universals::nchains(analysis), 2L)
  expect_identical(universals::nsims(analysis), 1000L)
  expect_identical(embr::ngens(analysis), 2000L)

  monitor <- analysis$cmdstan_fit$summary()
  rhat <- rhat(analysis, by = "term", as_df = TRUE)

  rhat_stan <- data.frame(
    term = as.term(monitor$variable),
    rhat = round(monitor[, "rhat"], 3)
  )
  rhat_stan <- rhat_stan[!(rhat_stan$term %in% c("lp__", "eAnnual")), ]
  expect_identical(sort(rhat$term), sort(rhat_stan$term))

  # ensure glance() requires that max_perc_divergent is a percentage
  expect_no_error(glance(analysis, max_perc_divergent = 0))
  expect_no_error(glance(analysis, max_perc_divergent = 100))
  expect_no_error(glance(analysis, max_perc_divergent = 10.1))
  expect_error(glance(analysis, max_perc_divergent = "0"), "must inherit from class 'numeric'")
  expect_error(glance(analysis, max_perc_divergent = 0L), "must inherit from class 'numeric'")
  expect_error(glance(analysis, max_perc_divergent = -1), "must be between 0 and 100")
  expect_error(glance(analysis, max_perc_divergent = 101), "must be between 0 and 100")
  
  glance <- glance(analysis)
  expect_s3_class(glance, "tbl")
  expect_identical(glance$n, 40L)
  expect_identical(glance$K, 5L)
  expect_identical(glance$nthin, 1L)

  expect_identical(
    colnames(glance),
    c(
      "n",
      "K",
      "nchains",
      "niters",
      "nthin",
      "ess",
      "rhat",
      "converged",
      "perc_divergent",
      "perc_max_treedepth",
      "ebfmi"
    )
  )

  waic <- IC(analysis)
  expect_gt(waic, 305)
  expect_lt(waic, 315)

  coef <- coef(analysis, simplify = TRUE)

  expect_s3_class(coef, "tbl")
  expect_s3_class(coef, "mb_analysis_coef")
  expect_identical(
    colnames(coef),
    c("term", "estimate", "lower", "upper", "svalue")
  )
  expect_identical(
    coef$term,
    sort(as.term(c("alpha", "beta1", "beta2", "beta3", "log_sAnnual")))
  )
  expect_identical(
    coef(analysis, "derived", simplify = TRUE)$term,
    as.term("sAnnual")
  )
  expect_identical(
    coef(analysis, "all", simplify = TRUE)$term,
    sort(
      as.term(
        c(
          "alpha",
          paste0("bAnnual[", 1:40, "]"),
          "beta1",
          "beta2",
          "beta3",
          "log_sAnnual",
          "sAnnual"
        )
      )
    )
  )

  tidy <- tidy(analysis)
  expect_identical(
    colnames(tidy),
    c("term", "estimate", "lower", "upper", "esr", "rhat")
  )

  year <- predict(analysis, new_data = "Year")

  expect_s3_class(year, "tbl")
  expect_identical(
    colnames(year),
    c(
      "Year",
      "Pairs",
      "R.Pairs",
      "Eyasses",
      "Annual",
      "estimate",
      "lower",
      "upper",
      "svalue"
    )
  )
  expect_true(all(year$estimate > year$lower))
  expect_true(all(year$estimate < year$upper))

  x <- unlist(estimates(analysis))
  names(x) <- NULL
  expect_equal(x, coef$estimate)
})

test_that("glance calculates divergent transitions and declares convergence correctly", {
  # a stub in place of the parent glance method so the test does not
  # require a fitted model
  local_mocked_s3_method(
    "glance",
    "stub_analysis",
    # converged gets flipped from TRUE to FALSE when divergences are too common
    function(x, ...) {
      data.frame(nchains = 4L, niters = 250L,
                 converged = x$cmdstan_fit$diagnostic_summary()$converged)
    }
  )

  stub_analysis <- function(num_divergent, num_max_treedepth, converged) {
    diag_summary <- list(
      num_divergent = num_divergent,
      num_max_treedepth = num_max_treedepth,
      ebfmi = rep(1, length(num_divergent)),
      converged = converged
    )
    structure(
      list(cmdstan_fit = list(diagnostic_summary = function() diag_summary)),
      class = c("cmdstan_mcmc_analysis", "stub_analysis")
    )
  }

  # 4 chains of 250 iterations = 1000 transitions
  glance <- glance(stub_analysis(c(3, 7, 0, 10), c(2, 0, 0, 3), TRUE))

  expect_identical(glance$perc_divergent, 2)
  expect_identical(glance$perc_max_treedepth, 0.5)
  expect_identical(glance$converged, FALSE) # based on divergences alone

  # no divergent transitions or max treedepth hits
  glance <- glance(stub_analysis(c(0, 0, 0, 0), c(0, 0, 0, 0), TRUE))

  expect_identical(glance$perc_divergent, 0)
  expect_identical(glance$perc_max_treedepth, 0)
  expect_identical(glance$converged, TRUE)
  
  # every transition divergent
  glance <- glance(stub_analysis(rep(250, 4), rep(250, 4), TRUE))

  expect_identical(glance$perc_divergent, 100)
  expect_identical(glance$perc_max_treedepth, 100)
  expect_identical(glance$converged, FALSE)
  
  # not converged due to other reasons besides divergences: should stay FALSE
  glance <- glance(stub_analysis(rep(250, 4), rep(250, 4), FALSE))
  expect_identical(glance$converged, FALSE)
  
  # not converged due to ESS or Rhat but divergences are ok: should stay FALSE
  glance <- glance(stub_analysis(rep(0, 4), rep(0, 4), FALSE))
  expect_identical(glance$converged, FALSE)
  
  # check that setting the option has an effect
  stub <- stub_analysis(c(1, 0, 0, 0), rep(0, 4), TRUE)
  
  withr::with_options(list(mb.prop_divergent = NULL), {
    expect_true(glance(stub)$converged)
  })
  withr::with_options(list(mb.prop_divergent = 0.002), {
    expect_true(glance(stub)$converged)
  })
  withr::with_options(list(mb.prop_divergent = 0), {
    expect_false(glance(stub)$converged)
  })
  
  stub <- stub_analysis(c(250, 250, 250, 250), rep(0, 4), TRUE)
  
  withr::with_options(list(mb.prop_divergent = NULL), {
    expect_false(glance(stub)$converged)
  })
  withr::with_options(list(mb.prop_divergent = 0), {
    expect_false(glance(stub)$converged)
  })
  withr::with_options(list(mb.prop_divergent = 1), {
    expect_true(glance(stub)$converged)
  })
})

test_that("glance reports divergent transitions for a funnel model", {
  # Neal's funnel in its centered parameterization: the group effects collapse
  # towards zero as sGroup shrinks, creating a neck the sampler cannot explore
  # without diverging. The vague prior on log_sGroup and the weak likelihood
  # (large observation sd, two observations per group) leave the funnel almost
  # entirely unconstrained by the data.
  model <- embr::model(
    mb_code(
      "
data {
  int nObs;
  int nGroup;
  array[nObs] int Group;
  array[nObs] real y;
}
parameters {
  real log_sGroup;
  vector[nGroup] bGroup;
}
transformed parameters {
  real sGroup;
  sGroup = exp(log_sGroup);
}
model {
  log_sGroup ~ normal(0, 10);
  bGroup ~ normal(0, sGroup);
  for (i in 1:nObs) {
    y[i] ~ normal(bGroup[Group[i]], 10);
  }
}"
    ),
    select_data = list("y" = numeric(), Group = factor()),
    random_effects = list(bGroup = "Group"),
    # start the chains high up the funnel, where the step size adapts to the
    # wide part of the posterior and then fails in the neck
    gen_inits = function(data) {
      list(log_sGroup = 10)
    }
  )

  data <- data.frame(
    y = c(-1, 1, -0.5, 0.5, -2, 2, 0, 0, -1.5, 1.5, -0.2, 0.2, -3, 3, -1, 1),
    Group = factor(rep(1:8, each = 2))
  )

  analysis <- embr::analyse(
    model,
    data = data,
    stan_engine = "cmdstan-mcmc",
    seed = 42,
    # a permissive target acceptance rate leaves the step size far too large
    # for the neck of the funnel, making divergences all but certain
    adapt_delta = 0.5
  )

  glance <- suppressMessages(glance(analysis, rhat = 5, esr = 0))

  expect_gt(glance$perc_divergent, 0)
  expect_identical(
    glance$perc_divergent,
    mean(suppressMessages(analysis$cmdstan_fit$diagnostic_summary())$num_divergent) / glance$niters * 100
  )
  expect_identical(glance$converged, FALSE)
})
