#' Read the versioned predictor scaling factors
#'
#' @param suffix Character. "" for v1, "_v2" for corrected version. Default "_v2".
#' @return The scaleParams data frame written by 09_computeScaleParams.R.
read_scale_params <- function(suffix) {
  path <- here::here("Analysis", "VegComposition", "ModelFitting", "models",
                     paste0("scaleParams", suffix, ".rds"))
  if (!file.exists(path)) stop("Not found: ", path, " -- run 09 first.")
  readRDS(path)
}