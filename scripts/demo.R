library(poispkgs)
library(smbr2)

jags_code <- "
  for (j in 1:nAnnual) {
    bAnnual[j] ~ dnorm(0, sAnnual^-2)
  }
  
  for (i in 1:nObs) {
    Pairs[i] ~ dpois(ePairs[i])
    ePairs[i] <- exp(alpha + beta1 * Year[i] + beta2 * pow(Year[i], 2) + 
                     beta3 * pow(Year[i], 3) + bAnnual[Annual[i]])
  }
"

n <- 500
years <- 1985:2024
year <- years
year <- sample(years, n, replace = TRUE)
df <- tibble(Year = year, Annual = factor(year))
df_scaled <- rescale(df, scale = "Year")
alpha <- 4.25
beta1 <- 1.2
beta2 <- -0.02
beta3 <- -0.25
sAnnual <- 0.1

n <- length(years)
consts <- list(Year = df_scaled$Year, Annual = as.integer(df_scaled$Annual), nObs = nrow(df), nAnnual = nrow(df))
params <- list(alpha = alpha, beta1 = beta1, beta2 = beta2, beta3 = beta3, sAnnual = sAnnual)
set.seed(123)
sim <- sims::sims_simulate(code = jags_code, constants = consts, parameters = params, nsims = 10)

df$Pairs <- as.integer(sim[[5]]$Pairs)

gp <- 
  ggplot(data = df) +
  geom_point(aes(x = Year, y = Pairs))

sbf_open_window()
sbf_print(gp)

model <- model(code = "
    data {
      int nAnnual;
      int nObs;
      array[nObs] int Annual;
      array[nObs] int Pairs;
      array[nObs] real Year;
  }
  parameters {
      vector[nAnnual] bAnnual;
      real<lower=0,upper=1> sAnnual;
      real alpha;
      real beta1;
      real beta2;
      real beta3;
  }
  model {
      vector[nObs] ePairs;
      sAnnual ~ exponential(1);
      bAnnual ~ normal(0, sAnnual);
      alpha ~ normal(0, 10);
      beta1 ~ normal(0, 10);
      beta2 ~ normal(0, 10);
      beta3 ~ normal(0, 10);
      for (i in 1:nObs) {
        ePairs[i] = exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 +
                      beta3 * Year[i]^3 + bAnnual[Annual[i]]);
      }
      target += poisson_lpmf(Pairs | ePairs);
  }
", new_expr = "
  for (i in 1:length(Pairs)) {
    prediction[i] <- exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 +
                       beta3 * Year[i]^3 + bAnnual[Annual[i]])
  }
", select_data = list(
  "Pairs" = integer(), 
  "Year*" = integer(),
  Annual = factor()
),
random_effects = list(bAnnual = "Annual"))

# new things:
# 	1. Improved documentation, analyse, analyse.mb_model etc.
#   2. Added seed (rstan and cmdstanr, not jags)
#   3. Added niters_warmup (warmup phase separate from thinning)
#   4. Progress in parallel 

# analyse
seed <- 123L
analysis <- analyse(model, 
                    data = df, 
                    seed = seed, 
                    quiet = FALSE,
                    parallel = TRUE,
                    nthin = 2L,
                    stan_engine = "cmdstan-mcmc")

#   5. model doesn't recompile if in same session
#   6. Pedantic model checking - https://mc-stan.org/docs/stan-users-guide/using-stanc.html#pedantic-mode
#   7. new glance output including more diagnostics
#   8. Diagnostics with diagnose()

diagnose(analysis)
glance(analysis)
?glance.cmdstan_mcmc_analysis

#   9. new parameter estimation engines - pathfinder, laplace, variational, optimize
# analyse pathfinder
analysis_path <- analyse(model, data = df, seed = 3L, quiet = FALSE, stan_engine = "cmdstan-pathfinder")

# analyse laplace
analysis_lap <- analyse(model, data = df, seed = 3L, quiet = FALSE, stan_engine = "cmdstan-laplace")

# coefficient table
coefs <- coef(analysis, simplify = TRUE)
coefs_path <- coef(analysis_path, simplify = TRUE)
coefs_lap <- coef(analysis_lap, simplify = TRUE)

coefs <- dplyr::bind_rows(list("mcmc" = coefs, 
                               "laplace" = coefs_lap,
                               "pathfinder" = coefs_path), .id = "engine") %>% 
  mutate(term = as.vector(term))

truth <- tibble(term = c("alpha", "beta1", "beta2", "beta3", "sAnnual"),
                value = c(alpha, beta1, beta2, beta3, sAnnual))

gp <- ggplot(data = coefs) +
  geom_point(data = truth, aes(x = term, y = value), color = "red") +
  geom_point(aes(x = term, y = estimate, color = engine), position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(x = term, y = estimate, ymin = lower, ymax = upper, color = engine),
                position = position_dodge(width = 0.5)) +
  facet_wrap(~term, scales = "free")

sbf_open_window(6, 4)
sbf_print(gp)

year <- predict(analysis, new_data = "Year")
year_path <- predict(analysis_path, new_data = "Year")
year_lap <- predict(analysis_lap, new_data = "Year")

years <- dplyr::bind_rows(list("mcmc" = year, 
                               # "laplace" = year_lap,
                               "pathfinder" = year_path), .id = "engine")

# plot those predictions
gp <- ggplot(data = years, aes(x = Year, y = estimate)) +
  geom_point(data = df, aes(y = Pairs), alpha = 0.1) +
  geom_line(aes(color = engine)) +
  geom_line(aes(y = lower, color = engine), linetype = "dotted") +
  geom_line(aes(y = upper, color = engine), linetype = "dotted") +
  expand_limits(y = 0)

sbf_open_window()
sbf_print(gp)

# access generated quantities
model <- model(code = "
    data {
      int nAnnual;
      int nObs;
      array[nObs] int Annual;
      array[nObs] int Pairs;
      array[nObs] real Year;
  }
  parameters {
      vector[nAnnual] bAnnual;
      real<lower=0,upper=1> sAnnual;
      real alpha;
      real beta1;
      real beta2;
      real beta3;
  }
  transformed parameters {
    vector[nObs] ePairs;
    for (i in 1:nObs) {
        ePairs[i] = exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 +
                      beta3 * Year[i]^3 + bAnnual[Annual[i]]);
      }
  }
  model {
      
      sAnnual ~ exponential(1);
      bAnnual ~ normal(0, sAnnual);
      alpha ~ normal(0, 10);
      beta1 ~ normal(0, 10);
      beta2 ~ normal(0, 10);
      beta3 ~ normal(0, 10);
      
      target += poisson_lpmf(Pairs | ePairs);
  }
  generated quantities {
      real<lower=0, upper=1> R_squared;
  vector[nObs] mu_pred;
  vector[nObs] zi_pred;
  vector[nObs] y_pred;
  real var_y_pred;
  real var_residual;
  
  y_pred = ePairs;
  var_y_pred = variance(y_pred);
  var_residual = variance(to_vector(Pairs) - y_pred);
  R_squared = var_y_pred / (var_y_pred + var_residual);
  }
", new_expr = "
  for (i in 1:length(Pairs)) {
    prediction[i] <- exp(alpha + beta1 * Year[i] + beta2 * Year[i]^2 +
                       beta3 * Year[i]^3 + bAnnual[Annual[i]])
  }
", select_data = list(
  "Pairs" = integer(), 
  "Year*" = integer(),
  Annual = factor()
),
derived = "R_squared",
random_effects = list(bAnnual = "Annual"))

analysis <- analyse(model, 
                    data = df, 
                    seed = seed, 
                    quiet = FALSE,
                    parallel = TRUE,
                    nthin = 2L,
                    stan_engine = "cmdstan-mcmc")

coef(analysis, param_type = "derived")

# extra tips
#   1. might as well use 4 chains
#   2. access additional methods through the model fit object analysis$cmdstan_fit (R6)
#   3. pass additional args via ... - will warn if ignored due to conflict with embr argument (.e.g., iter_sampling)
#   4. use pathfinder and pass model object as inits - setting init will override embr inits

