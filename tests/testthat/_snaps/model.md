# pars derived(

    Code
      pars(model)
    Output
      [1] "bar"        "foo"        "mu_y"       "sigma_y"    "tau_y"     
      [6] "variance_y"

---

    Code
      pars(model, "primary")
    Output
      [1] "foo"   "mu_y"  "tau_y"

---

    Code
      pars(model, "primary", scalar = TRUE)
    Output
      [1] "mu_y"  "tau_y"

---

    Code
      pars(model, param_type = "derived")
    Output
      [1] "bar"        "sigma_y"    "variance_y"

---

    Code
      pars(model, param_type = "derived", scalar = TRUE)
    Output
      [1] "bar"        "sigma_y"    "variance_y"

---

    Code
      pars(model, "fixed", scalar = TRUE)
    Output
      [1] "mu_y"  "tau_y"

---

    Code
      embr::monitor(model)
    Output
      [1] "bar"        "mu_y"       "sigma_y"    "tau_y"      "variance_y"

