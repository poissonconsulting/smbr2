# Muffles messages and warnings (e.g. 'Compiling Stan program...') but replays
# them if an error occurs so informative context such as stanc syntax errors
# or failed-chain warnings stays visible under quiet = TRUE (#34).
quiet_capture <- function(x) {
  conditions <- list()
  collect <- function(restart) {
    function(cnd) {
      conditions[[length(conditions) + 1L]] <<- cnd
      invokeRestart(restart)
    }
  }
  tryCatch(
    withCallingHandlers(
      capture.output(x),
      message = collect("muffleMessage"),
      warning = collect("muffleWarning")
    ),
    error = function(e) {
      for (cnd in conditions) {
        if (inherits(cnd, "warning")) warning(cnd) else message(cnd)
      }
      stop(e)
    }
  )
}
