# For running other scripts

library(callr)


# params ------------------------------------------------------------------

run_prep <- TRUE
run_02 <- TRUE
run_03 <- FALSE
suffix <- "_v2" # "_v2" = updated (v2) climate data; "" = original


# data prep ---------------------------------------------------------------


prep_scripts <- c(
  "Analysis/VegComposition/DataPrep/06_GettingWeatherData.R",
  "Analysis/VegComposition/DataPrep/07_AddEcoregion.R",
  "Analysis/VegComposition/DataPrep/08_GetSoilsData.R",
  "Analysis/VegComposition/DataPrep/09_computeScaleParams.R"
)

if (run_prep) {
  for (s in prep_scripts) {
    cat("\n==== START", s, "----", format(Sys.time()), "====\n")
    callr::rscript(s)
    cat("==== DONE ", s, "----", format(Sys.time()), "====\n")
  }
  cat("\n==== ALL PREP SCRIPTS COMPLETE ====\n\n")
}

# Global forest (tree / no-tree) model ------------------------------------------
# Knit 02_modelFitting_globalForestModel.Rmd. The suffix is passed to the Rmd
# (so it reads the matching v2 data & writes v2 model outputs) and appended to
# the html filename, so a "_v2" run does not overwrite the original html.


if(run_02) {
  rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/02_modelFitting_globalForestModel.Rmd",
                    params = list(  run = TRUE,
                                    save_figs = TRUE,
                                    ecoregion = "CONUS",
                                    response = "TotalTreeCover",
                                    treeThreshold = 10,
                                    whichSecondBestMod = "halfse",
                                    thresholdMethod = "PredPrev=Obs",
                                    suffix = suffix),
                    output_format = "html_document",
                    output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                    output_file = paste0("02_modelFitting_globalForestModel", suffix, ".html"))
}

if(run_03){
# Beta-version: noTree ; yes trim anomalies---------------------------------------------------
# total herbaceous cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = FALSE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "noTrees",
#                                   response = "TotalHerbaceousCover",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_NoTrees_TotalHerbaceousCover_trimAnom.html")
# 
#total tree cover
rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd",
                  params = list(  run = FALSE,
                                  allowAllTreeData = TRUE,
                                  save_figs = FALSE,
                                  trimAnomalies = TRUE,
                                  ecoregion = "noTrees",
                                  response = "TotalTreeCover",
                                  removeTexasLouisianaPlain = FALSE,
                                  removeAllAnoms = TRUE,
                                  whichSecondBestMod= "auto"),
                  output_format = "html_document",
                  output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                  output_file = "betaLASSO_NoTrees_TotalTreeCover.html")

# #total shrub cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "noTrees",
#                                   response = "ShrubCover",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_NoTrees_ShrubCover_trimAnoms.html")

# #bare ground cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "noTrees",
#                                   response = "BareGroundCover",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_NoTrees_BareGroundCover_trimAnoms.html")

# #C4 graminoid cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "noTrees",
#                                   response = "C4GramCover_prop",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_NoTrees_C4GramCover_trimAnoms.html")
# #C3 graminoid cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "noTrees",
#                                   response = "C3GramCover_prop",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_NoTrees_C3GramCover_trimAnoms.html")
# #broad leaved tree cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "shrubGrass",
#                                   response = "AngioTreeCover_prop",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_GrassShrub_AngioTreeCover_prop.html")
# #conifer tree cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "shrubGrass",
#                                   response = "ConifTreeCover_prop",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_GrassShrub_ConifTreeCover_prop.html")
# #forb cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "noTrees",
#                                   response = "ForbCover_prop",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_NoTrees_ForbCover_trimAnoms.html")
#Beta-version:  yes trees ecoregion; yes trim anomalies- --------------------------------------------------------

# # total herbaceous cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "trees",
#                                   response = "TotalHerbaceousCover",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
#                   output_file = "betaLASSO_YesTrees_TotalHerbaceousCover_trimAnom.html")

#total tree cover
rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
                  params = list(  run = FALSE, 
                                  allowAllTreeData = TRUE,
                                  save_figs = FALSE,
                                  trimAnomalies = TRUE,
                                  ecoregion = "trees",
                                  response = "TotalTreeCover",
                                  removeTexasLouisianaPlain = FALSE,
                                  removeAllAnoms = FALSE,
                                  whichSecondBestMod= "auto"), 
                  output_format = "html_document", 
                  output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                  output_file = "betaLASSO_YesTrees_TotalTreeCover_trimAnom.html"
)

# #total shrub cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "trees",
#                                   response = "ShrubCover",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_YesTrees_ShrubCover_trimAnom.html")
# 
# 
# #C4 graminoid cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "trees",
#                                   response = "C4GramCover_prop",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_YesTrees_C4GramCover_prop_trimAnom.html")
# #C3 graminoid cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "trees",
#                                   response = "C3GramCover_prop",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_YesTrees_C3GramCover_prop_trimAnom.html")
# #broad leaved tree cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "trees",
#                                   response = "AngioTreeCover_prop",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_YesTrees_AngioTreeCover_prop_trimAnom.html")
# #conifer tree cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "trees",
#                                   response = "ConifTreeCover_prop",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_YesTrees_ConifTreeCover_prop_trimAnom.html")
# #forb cover
# rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
#                   params = list(  run = TRUE, 
#                                   
#                                   save_figs = FALSE,
#                                   trimAnomalies = TRUE,
#                                   ecoregion = "trees",
#                                   response = "ForbCover_prop",
#                                   removeTexasLouisianaPlain = FALSE,
#                                   removeAllAnoms = FALSE,
#                                   whichSecondBestMod= "auto"), 
#                   output_format = "html_document", 
#                   output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/",
#                   output_file = "betaLASSO_YesTrees_ForbCover_prop_trimAnom.html")

#Beta-version:  CONUS-wide models; yes trim anomalies- ------------------------------------------------
# total herbaceous cover
rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
                  params = list(  run = FALSE, 
                                  allowAllTreeData = TRUE,
                                  save_figs = FALSE,
                                  trimAnomalies = TRUE,
                                  ecoregion = "CONUS",
                                  response = "TotalHerbaceousCover",
                                  removeTexasLouisianaPlain = FALSE,
                                  removeAllAnoms = FALSE,
                                  whichSecondBestMod= "auto"), 
                  output_format = "html_document", 
                  output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                  output_file = "betaLASSO_CONUS_TotalHerbaceousCover_trimAnom.html")
# total shrub cover
rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd",
                  params = list(run = FALSE, 
                                allowAllTreeData = TRUE,
                                  save_figs = FALSE,
                                  trimAnomalies = TRUE,
                                  ecoregion = "CONUS",
                                  response = "ShrubCover",
                                  removeTexasLouisianaPlain = FALSE,
                                  removeAllAnoms = FALSE,
                                  whichSecondBestMod= "auto"),
                  output_format = "html_document",
                  output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                  output_file = "betaLASSO_CONUS_ShrubCover_trimAnom.html")
# 
# 
# total bare ground cover
rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd",
                  params = list(  run = FALSE, 
                                  allowAllTreeData = TRUE,
                                  save_figs = FALSE,
                                  trimAnomalies = TRUE,
                                  ecoregion = "CONUS",
                                  response = "BareGroundCover",
                                  removeTexasLouisianaPlain = FALSE,
                                  removeAllAnoms = FALSE,
                                  whichSecondBestMod= "auto"),
                  output_format = "html_document",
                  output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                  output_file = "betaLASSO_CONUS_BareGroundCover_trimAnom.html")

#C4 graminoid cover
rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
                  params = list(  run = FALSE, 
                                  allowAllTreeData = TRUE, 
                                  save_figs = FALSE,
                                  trimAnomalies = TRUE,
                                  ecoregion = "CONUS",
                                  response = "C4GramCover_prop",
                                  removeTexasLouisianaPlain = FALSE,
                                  removeAllAnoms = FALSE,
                                  whichSecondBestMod= "auto"), 
                  output_format = "html_document", 
                  output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                  output_file = "betaLASSO_CONUS_C4GramCover_prop_trimAnom.html")
#C3 graminoid cover
rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
                  params = list(  run = FALSE, 
                                  allowAllTreeData = TRUE,
                                  save_figs = FALSE,
                                  trimAnomalies = TRUE,
                                  ecoregion = "CONUS",
                                  response = "C3GramCover_prop",
                                  removeTexasLouisianaPlain = FALSE,
                                  removeAllAnoms = FALSE,
                                  whichSecondBestMod= "auto"), 
                  output_format = "html_document", 
                  output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                  output_file = "betaLASSO_CONUS_C3GramCover_prop_trimAnom.html")
#broad leaved tree cover
rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
                  params = list(  run = FALSE, 
                                  allowAllTreeData = TRUE,
                                  save_figs = FALSE,
                                  trimAnomalies = TRUE,
                                  ecoregion = "CONUS",
                                  response = "AngioTreeCover_prop",
                                  removeTexasLouisianaPlain = FALSE,
                                  removeAllAnoms = FALSE,
                                  whichSecondBestMod= "auto"), 
                  output_format = "html_document", 
                  output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                  output_file = "betaLASSO_CONUS_AngioTreeCover_prop_trimAnom.html")
#conifer tree cover
rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
                  params = list(  run = FALSE, 
                                  allowAllTreeData = TRUE, 
                                  save_figs = FALSE,
                                  trimAnomalies = TRUE,
                                  ecoregion = "CONUS",
                                  response = "ConifTreeCover_prop",
                                  removeTexasLouisianaPlain = FALSE,
                                  removeAllAnoms = FALSE,
                                  whichSecondBestMod= "auto"), 
                  output_format = "html_document", 
                  output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                  output_file = "betaLASSO_CONUS_ConifTreeCover_prop_trimAnom.html")
#forb cover
rmarkdown::render(input = "./Analysis/VegComposition/ModelFitting/03_modelFitting_testingBetaLASSO.Rmd", 
                  params = list(  run = FALSE, 
                                  allowAllTreeData = TRUE,
                                  save_figs = FALSE,
                                  trimAnomalies = TRUE,
                                  ecoregion = "CONUS",
                                  response = "ForbCover_prop",
                                  removeTexasLouisianaPlain = FALSE,
                                  removeAllAnoms = FALSE,
                                  whichSecondBestMod= "auto"), 
                  output_format = "html_document", 
                  output_dir = "./Analysis/VegComposition/ModelFitting/outputHtmls/ModelsWeUseDownstream/",
                  output_file = "betaLASSO_CONUS_ForbCover_prop_trimAnom.html")

}

