.onLoad <- function(libname, pkgname) {
  registerS3method(
    "check_model_pars",
    "smb_code",
    getS3method("check_model_pars", "smb_code", envir = asNamespace("smbr")),
    envir = asNamespace("embr")
  )
  registerS3method(
    "comment_string",
    "smb_code",
    getS3method("comment_string", "smb_code", envir = asNamespace("smbr")),
    envir = asNamespace("embr")
  )
  registerS3method(
    "pars",
    "smb_code",
    getS3method("pars", "smb_code", envir = asNamespace("smbr")),
    envir = asNamespace("embr")
  )
  registerS3method(
    "pars",
    "smb_model",
    getS3method("pars", "smb_model", envir = asNamespace("smbr")),
    envir = asNamespace("embr")
  )
  registerS3method(
    "sd_priors_by",
    "smb_code",
    getS3method("sd_priors_by", "smb_code", envir = asNamespace("smbr")),
    envir = asNamespace("embr")
  )
}

#' @export
#' @importFrom smbr is.smb_code
smbr::is.smb_code

#' @export
#' @importFrom smbr is.smb_model
smbr::is.smb_model
