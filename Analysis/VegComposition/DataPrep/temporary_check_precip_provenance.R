# check_precip_provenance.R

# temporary file--for debugging (July, 26), doesn't create any output used elsewhere
# ---------------------------------------------------------------------------
# Question: does the site pipeline's SAVED per-year prcp_annTotal match what you
# get by re-extracting the CURRENT yearly Daymet rasters at the SAME coordinates
# the site pipeline stored?
#
#   - If they DISAGREE  -> the saved site artifact was built from different raw
#                          bytes than what is on disk now (stale / re-download
#                          mismatch). Root cause is upstream of any aggregation.
#   - If they AGREE     -> the raw annual precip input is identical; the
#                          site-vs-gridded gap is NOT in the extracted input.
#                          It is in aggregation (the 31-yr normal) or coordinate
#                          handling, or on the gridded side.
#
# No pipeline rerun. Reads a few points from saved files + a handful of rasters.
# Run from the project root (same working directory as 06_GettingWeatherData.R).
# ---------------------------------------------------------------------------

library(tidyverse)
library(terra)

set.seed(1)
n_loc <- 8L                                   # locations to check
clim_window <- 1992:2022                      # the 2023 CLIM window used by 06 originally (switched to 30 yr)

ydir           <- "./Data_raw/dayMet/yearly"
annual_pattern <- "prcp_annttl_na_.....tif$"
grid_v2        <- "./Data_processed/WallToWallClimateData/DayMetData_allCONUS_2023ClimateValues_raster_v2.tif"

# --- 1. find a saved site artifact holding per-year prcp_annTotal + Long/Lat ----
# ordered rawest-first: the extraction dump is the purest record of the input.
candidates <- c(
  "./Data_processed/CoverData/dayMet_intermediate/TEMP_extract_v2/prcpPoints_ann.rds"
)
site <- NULL; site_file <- NA_character_
for (f in candidates) {
  if (file.exists(f)) {
    tmp <- readRDS(f)
    if (all(c("year", "prcp_annTotal", "Long", "Lat") %in% names(tmp))) {
      print(f)
      site <- as_tibble(tmp); site_file <- f; break
    }
  }
}
if (is.null(site)) {
  stop("No saved artifact with columns year/prcp_annTotal/Long/Lat found.\n",
       "Checked:\n  ", paste(candidates, collapse = "\n  "),
       "\nEdit `candidates` to point at a file that has those columns.")
}
message("Using saved site artifact:\n  ", site_file)

site <- site %>%
  select(year, Long, Lat, prcp_annTotal) %>%
  filter(is.finite(prcp_annTotal), is.finite(Long), is.finite(Lat))

# quick sanity: are Long/Lat projected metres (expected) or degrees?
message(sprintf("Long range [%.1f, %.1f], Lat range [%.1f, %.1f]  (expect LCC metres, |x|>1e5)",
                min(site$Long), max(site$Long), min(site$Lat), max(site$Lat)))

# --- 2. sample unique locations ------------------------------------------------
locs <- site %>%
  distinct(Long, Lat) %>%
  slice_sample(., n = min(c(n_loc, nrow(.)))) %>%
  mutate(loc = row_number())

site_s <- site %>%
  inner_join(locs, by = c("Long", "Lat")) %>%
  distinct(loc, year, .keep_all = TRUE)       # guard against any dup rows

# --- 3. yearly rasters + years from filenames ----------------------------------
files <- list.files(ydir, pattern = annual_pattern, full.names = TRUE)
if (length(files) == 0)
  stop("No yearly precip rasters in ", ydir, " matching ", annual_pattern)
file_years <- as.integer(str_extract(basename(files), "\\d{4}"))
ord <- order(file_years); files <- files[ord]; file_years <- file_years[ord]

# --- 4. points in the raster CRS (stored Long/Lat are already that CRS) ---------
r1  <- rast(files[1])
pts <- vect(as.matrix(locs[, c("Long", "Lat")]), type = "points", crs = crs(r1))

# --- 5. re-extract every yearly raster at those points -------------------------
stk <- rast(files); names(stk) <- as.character(file_years)
reext <- terra::extract(stk, pts, ID = FALSE) %>%
  as_tibble() %>%
  mutate(loc = locs$loc) %>%
  pivot_longer(-loc, names_to = "year", values_to = "prcp_reextracted") %>%
  mutate(year = as.integer(year))

# --- 6. per (location, year): stored vs re-extracted ---------------------------
cmp <- site_s %>%
  transmute(loc, year, prcp_stored = prcp_annTotal) %>%
  inner_join(reext, by = c("loc", "year")) %>%
  mutate(adiff = abs(prcp_reextracted - prcp_stored))

cat("\n==== per (location, year): |re-extracted - stored| prcp_annTotal (mm) ====\n")
print(cmp %>% arrange(desc(adiff)) %>% head(25), n = 25)

cat("\n==== summary of |difference| across all checked location-years (mm) ====\n")
print(summary(cmp$adiff))
cat(sprintf("fraction matching to float (|diff| < 1e-2 mm): %.3f  (n = %d obs, %d locs)\n",
            mean(cmp$adiff < 1e-2), nrow(cmp), nrow(locs)))

# --- 7. the quantity actually in question: the 1992-2022 normal ---------------
# stored normal vs re-extracted normal vs (optionally) the gridded raster cell.
norm_tbl <- cmp %>%
  filter(year %in% clim_window) %>%
  group_by(loc) %>%
  summarise(n_yrs          = n(),
            normal_stored  = mean(prcp_stored),
            normal_reext   = mean(prcp_reextracted),
            .groups = "drop") %>%
  left_join(locs, by = "loc")

if (file.exists(grid_v2)) {
  rgrid <- rast(grid_v2)[["prcp_meanAnnTotal_CLIM"]]
  norm_tbl$normal_gridded <-
    terra::extract(rgrid, vect(as.matrix(norm_tbl[, c("Long", "Lat")]),
                               type = "points", crs = crs(rgrid)), ID = FALSE)[[1]]
} else {
  message("(gridded raster not found at ", grid_v2, " - skipping gridded column)")
  norm_tbl$normal_gridded <- NA_real_
}

cat("\n==== 1992-2022 precip normal: stored vs re-extracted vs gridded (mm) ====\n")
print(norm_tbl %>%
        mutate(d_reext_vs_stored = normal_reext   - normal_stored,
               d_grid_vs_stored  = normal_gridded  - normal_stored,
               d_grid_vs_reext = normal_gridded - normal_reext) %>%
        select(loc, n_yrs, normal_stored, normal_reext, normal_gridded,
               d_reext_vs_stored, d_grid_vs_stored, d_grid_vs_reext) %>%
        mutate(across(where(is.numeric), ~round(.x, 4))))

cat("\n---------------------------------------------------------------\n")
cat("READ:\n")
cat(" * per-year |diff| ~0 (float)  -> raw annual input is IDENTICAL; the gap is\n")
cat("   downstream (aggregation/coords) or on the gridded side, NOT the input.\n")
cat(" * per-year |diff| non-trivial -> saved site artifact was built from different\n")
cat("   raw bytes than the rasters now on disk (stale / re-download mismatch).\n")
cat(" * d_grid_vs_stored is the ~1% site-vs-gridded gap; d_reext_vs_stored isolates\n")
cat("   how much of it (if any) is already present in the raw yearly input.\n")
cat("---------------------------------------------------------------\n")
