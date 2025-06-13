.onLoad <- function(libname, pkgname) {
  registerS3method("check_model_pars", "smb_code", smbr:::check_model_pars.smb_code,
                   envir = asNamespace("embr"))
  registerS3method("comment_string", "smb_code", smbr:::comment_string.smb_code,
                   envir = asNamespace("embr"))
  registerS3method("pars", "smb_code", smbr:::pars.smb_code,
                   envir = asNamespace("embr"))
  registerS3method("pars", "smb_model", smbr:::pars.smb_model,
                   envir = asNamespace("embr"))
  registerS3method("sd_priors_by", "smb_code", smbr:::sd_priors_by.smb_code,
                   envir = asNamespace("embr"))
}

#' @export
#' @importFrom smbr is.smb_code
smbr::is.smb_code

#' @export
#' @importFrom smbr is.smb_model
smbr::is.smb_model