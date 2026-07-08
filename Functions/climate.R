# saturation vapor pressure
svp <- function(x) {
  # constants for SVP calculation
  #calculate SVP according to Williams et al NatCC 2012 supplementary material -  units haPa
  # https://static-content.springer.com/esm/art%3A10.1038%2Fnclimate1693/MediaObjects/41558_2013_BFnclimate1693_MOESM272_ESM.pdf
  a0<-6.107799961
  a1<-0.4436518521
  a2<-0.01428945805
  a3<-0.0002650648471
  a4<-0.000003031240396
  a5<-0.00000002034080948
  a6<-0.00000000006136820929
  svp_hapa <- (a0+ x*(a1+ x *(a2+ x *(a3+ x *(a4	+ x *(a5	+ x *a6)))))) # eq S1
  svp_hapa
}

vpd <- function(tmean, tmin) {
  t_dewpoint <- tmin # approximation
  svp_mean <- svp(tmean)
  svp_dew_approx <- svp(t_dewpoint) # approximate actual vapor pressure
  vpd <- (svp_mean - svp_dew_approx)
  vpd
}