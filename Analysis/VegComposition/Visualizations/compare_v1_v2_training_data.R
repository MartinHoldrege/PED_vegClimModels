#///////////////////////////////////////////////////////////////////////////
# Compare v1 vs v2 training data (weighted-mean climate fix).
# Reads the two versions of the model-fitting file (the 08 output used by 02),
# aligns rows by location + year (NOT by position -- v2 deduped extraction so
# order/rows may differ), computes RMSE and correlation per soils/climate
# variable, and scatterplots variables whose RMSE exceeds 1% of that
# variable's standard deviation.

# started July 2026
#///////////////////////////////////////////////////////////////////////////

library(tidyverse)


# --- files (the training file 02 reads) -------------------------------------
f_v1 <- file.path("Data_processed", "CoverData",
             "DataForModels_spatiallyAveraged_withSoils_noSf_sampledLANDFIRE.rds")
f_v2 <- file.path("Data_processed", "CoverData",
             "DataForModels_spatiallyAveraged_withSoils_noSf_sampledLANDFIRE_v2.rds")

v1 <- readRDS(f_v1)
v2 <- readRDS(f_v2)

# --- join key: location + year (discovered, not positional) -----------------
pick_keys <- function(df) {
  year_col <- intersect(c("Year", "year"), names(df))[1]
  c("x_vegDat", "y_vegDat", year_col)
}
keys <- pick_keys(v1)
message("Joining on keys: ", paste(keys, collapse = ", "))
stopifnot(all(keys %in% names(v1)), all(keys %in% names(v2)))

# --- restrict to soils + climate variables ----------------------------------
soil_cols <- c("soilDepth", "surfaceClay_perc", "avgSandPerc_acrossDepth",
               "avgCoarsePerc_acrossDepth", "avgOrganicCarbonPerc_0_3cm",
               "totalAvailableWaterHoldingCapacity")

# base (single-year) climate variables — directly changed by the weighted-mean fix
base_climate <- c("prcp_annTotal", "tmin_annAvg", "tmax_annAvg", "totalAnnPrecip",
                  "T_warmestMonth", "T_coldestMonth", "Tmin_annAvgOfMonthly",
                  "Tmax_annAvgOfMonthly", "precip_wettestMonth", "precip_driestMonth",
                  "precip_Seasonality", "PrecipTempCorr", "aboveFreezing_month",
                  "lastAboveFreezing_month", "isothermality", "durationFrostFreeDays",
                  "tmean", "annWaterDeficit", "annWetDegDays",
                  "annVPD_mean", "annVPD_max", "annVPD_min")

# windowed / anomaly climate variables: *_CLIM, *_3yr, *_3yrAnom, *percentile*
is_windowed_climate <- function(nm) str_detect(nm, "_CLIM$|_3yr$|_3yrAnom$|percentile")

num_cols <- names(v1)[sapply(v1, is.numeric)]
compare_cols <- num_cols[
  num_cols %in% soil_cols |
    num_cols %in% base_climate |
    is_windowed_climate(num_cols)
]
# drop the Start_* bookkeeping columns if caught, and the join keys
compare_cols <- setdiff(compare_cols, c(keys, "Start_CLIM", "Start_3yr", "uniqueID", "cell"))
compare_cols <- intersect(compare_cols, names(v2))   # must exist in both
message("Comparing ", length(compare_cols), " soils/climate variables.")


# --- align rows by key, keep rows in both -----------------------------------
v1s <- v1 %>% select(all_of(c(keys, compare_cols)))
v2s <- v2 %>% select(all_of(c(keys, compare_cols)))
joined <- inner_join(v1s, v2s, by = keys, suffix = c("_v1", "_v2"))
message("Rows: v1 = ", nrow(v1s), ", v2 = ", nrow(v2s),
        ", matched = ", nrow(joined))

# --- RMSE + correlation per variable ----------------------------------------
metrics <- map_dfr(compare_cols, function(v) {
  a <- joined[[paste0(v, "_v1")]]; b <- joined[[paste0(v, "_v2")]]
  ok <- is.finite(a) & is.finite(b); a <- a[ok]; b <- b[ok]
  tibble(
    variable  = v,
    type      = if (v %in% soil_cols) "soil" else "climate",
    n         = length(a),
    rmse      = sqrt(mean((b - a)^2)),
    sd_v1     = sd(a),
    nrmse     = sqrt(mean((b - a)^2)) / sd(a),
    cor       = if (length(a) > 2) cor(a, b) else NA_real_,
    mean_diff = mean(b - a)
  )
}) %>% arrange(cor)

print(metrics, n = Inf)
write_csv(metrics, file.path("Data_processed", "CoverData", "v1_v2_comparison_metrics.csv"))

# --- plot variables with RMSE > 1% of their SD ------------------------------
plot_vars <- metrics %>% filter(nrmse > 0.01) %>% pull(variable)
message("Non-trivial (rmse > 1% of sd): ", length(plot_vars))

if (length(plot_vars) > 0) {
  plot_df <- map_dfr(plot_vars, function(v) {
    tibble(variable = v,
           v1 = joined[[paste0(v, "_v1")]],
           v2 = joined[[paste0(v, "_v2")]])
  }) %>% filter(is.finite(v1) & is.finite(v2))

  if (nrow(plot_df) > 200000) {
    plot_df <- plot_df %>% group_by(variable) %>%
      slice_sample(n = 20000) %>% ungroup()
    message("Thinned to 20k points/variable for plotting.")
  }

  p <- ggplot(plot_df, aes(v1, v2)) +
    geom_point(alpha = 0.15, size = 0.4) +
    geom_abline(slope = 1, intercept = 0, color = "red", linewidth = 0.4) +
    facet_wrap(~variable, scales = "free") +
    labs(x = "v1 (original)", y = "v2 (corrected)",
         title = "Training soils/climate: v1 vs v2 (red = 1:1)") +
    theme_classic()+
    theme(strip.text = element_text(size = 9))

  ggsave(file.path("Figures", "CoverDatFigures", "Predictors", "v1_v2_comparison_scatter.png"),
         p, width = 30, height = 24, dpi = 300)

  message("Saved scatterplot.")
} else {
  message("No non-trivial differences found.")
}
