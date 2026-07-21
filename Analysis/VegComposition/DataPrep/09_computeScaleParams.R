#///////////////////////////////////////////////////////////////////////////
# Compute predictor scaling factors (center/scale) as a standalone, versioned
# artifact, so every downstream script scales identically without depending on
# 03 (training) or 05 (prediction) having run first.
#
# Produces `scaleParams{suffix}.rds`: a one-row data frame where each `{var}_s`
# column holds the base::scale() attributes (scaled:center, scaled:scale) --
# the exact object 02B and 05 rebuild inline. Extracting it here breaks the
# 05 <-> 02B circular dependency.
#
# This reproduces 02's rename + scale sequence EXACTLY (same predictor names,
# same unfiltered row set -- 02 scales before any row filtering), so the
# resulting factors are identical to what 02/03 produce.
#
# Back-compatible: suffix <- ""   -> v1 (scaleParams.rds)
#                  suffix <- "_v2" -> v2 (scaleParams_v2.rds)
#///////////////////////////////////////////////////////////////////////////

library(tidyverse)
library(sf)
library(here)

# --- settings ---------------------------------------------------------------
suffix <- "_v2"   # "" for v1, "_v2" for corrected-climate version

# --- read the training data (same file 02 reads) ----------------------------
modDat <- readRDS(
  here("Data_processed", "CoverData",
       paste0("DataForModels_spatiallyAveraged_withSoils_noSf_sampledLANDFIRE",
              suffix, ".rds"))
) %>% st_drop_geometry()

# --- reproduce 02's rename to short predictor names --------------------------
# (02 drops the raw monthly cols, then renames CLIM/anomaly cols to short names.
#  Row set is untouched; only columns are dropped/renamed.)
modDat_1 <- modDat %>%
  dplyr::select(-c(prcp_annTotal:annVPD_min)) %>%
  rename(
    "tmin" = tmin_meanAnnAvg_CLIM,
    "tmax" = tmax_meanAnnAvg_CLIM,
    "tmean" = tmean_meanAnnAvg_CLIM,
    "prcp" = prcp_meanAnnTotal_CLIM,
    "t_warm" = T_warmestMonth_meanAnnAvg_CLIM,
    "t_cold" = T_coldestMonth_meanAnnAvg_CLIM,
    "prcp_wet" = precip_wettestMonth_meanAnnAvg_CLIM,
    "prcp_dry" = precip_driestMonth_meanAnnAvg_CLIM,
    "prcp_seasonality" = precip_Seasonality_meanAnnAvg_CLIM,
    "prcpTempCorr" = PrecipTempCorr_meanAnnAvg_CLIM,
    "abvFreezingMonth" = aboveFreezing_month_meanAnnAvg_CLIM,
    "isothermality" = isothermality_meanAnnAvg_CLIM,
    "annWatDef" = annWaterDeficit_meanAnnAvg_CLIM,
    "annWetDegDays" = annWetDegDays_meanAnnAvg_CLIM,
    "VPD_mean" = annVPD_mean_meanAnnAvg_CLIM,
    "VPD_max" = annVPD_max_meanAnnAvg_CLIM,
    "VPD_min" = annVPD_min_meanAnnAvg_CLIM,
    "VPD_max_95" = annVPD_max_95percentile_CLIM,
    "annWatDef_95" = annWaterDeficit_95percentile_CLIM,
    "annWetDegDays_5" = annWetDegDays_5percentile_CLIM,
    "frostFreeDays_5" = durationFrostFreeDays_5percentile_CLIM,
    "frostFreeDays" = durationFrostFreeDays_meanAnnAvg_CLIM,
    "soilDepth" = soilDepth,
    "clay" = surfaceClay_perc,
    "sand" = avgSandPerc_acrossDepth,
    "coarse" = avgCoarsePerc_acrossDepth,
    "carbon" = avgOrganicCarbonPerc_0_3cm,
    "AWHC" = totalAvailableWaterHoldingCapacity,
    ## anomaly variables
    tmean_anom = tmean_meanAnnAvg_3yrAnom,
    tmin_anom = tmin_meanAnnAvg_3yrAnom,
    tmax_anom = tmax_meanAnnAvg_3yrAnom,
    prcp_anom = prcp_meanAnnTotal_3yrAnom,
    t_warm_anom = T_warmestMonth_meanAnnAvg_3yrAnom,
    t_cold_anom = T_coldestMonth_meanAnnAvg_3yrAnom,
    prcp_wet_anom = precip_wettestMonth_meanAnnAvg_3yrAnom,
    precp_dry_anom = precip_driestMonth_meanAnnAvg_3yrAnom,
    prcp_seasonality_anom = precip_Seasonality_meanAnnAvg_3yrAnom,
    prcpTempCorr_anom = PrecipTempCorr_meanAnnAvg_3yrAnom,
    aboveFreezingMonth_anom = aboveFreezing_month_meanAnnAvg_3yrAnom,
    isothermality_anom = isothermality_meanAnnAvg_3yrAnom,
    annWatDef_anom = annWaterDeficit_meanAnnAvg_3yrAnom,
    annWetDegDays_anom = annWetDegDays_meanAnnAvg_3yrAnom,
    VPD_mean_anom = annVPD_mean_meanAnnAvg_3yrAnom,
    VPD_min_anom = annVPD_min_meanAnnAvg_3yrAnom,
    VPD_max_anom = annVPD_max_meanAnnAvg_3yrAnom,
    VPD_max_95_anom = annVPD_max_95percentile_3yrAnom,
    annWatDef_95_anom = annWaterDeficit_95percentile_3yrAnom,
    annWetDegDays_5_anom = annWetDegDays_5percentile_3yrAnom,
    frostFreeDays_5_anom = durationFrostFreeDays_5percentile_3yrAnom,
    frostFreeDays_anom = durationFrostFreeDays_meanAnnAvg_3yrAnom
  ) %>%
  dplyr::select(-c(tmin_meanAnnAvg_3yr:durationFrostFreeDays_meanAnnAvg_3yr))

# --- scale predictors exactly as 02/03 do (unfiltered rows) -----------------
allPreds <- modDat_1 %>%
  dplyr::select(tmin:frostFreeDays, tmean_anom:frostFreeDays_anom,
                soilDepth:AWHC) %>%
  names()

modDat_1_s <- modDat_1 %>%
  mutate(across(all_of(allPreds), base::scale, .names = "{.col}_s"))

# --- extract the scaling factors (exact structure 02B/05 consume) -----------
scaleParams <- modDat_1_s %>%
  dplyr::select(tmin_s:AWHC_s) %>%
  reframe(across(all_of(names(.)), attributes))

# --- save -------------------------------------------------------------------
out_path <- here("Analysis", "VegComposition", "ModelFitting", "models",
                 paste0("scaleParams", suffix, ".rds"))
saveRDS(scaleParams, out_path)

message("Wrote ", out_path, "  (", ncol(scaleParams), " scaled predictors)")
print(allPreds)
