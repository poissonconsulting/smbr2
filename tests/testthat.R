Sys.setenv("R_TESTS" = "")

library(testthat)
library(smbr2)

test_check("smbr2")
