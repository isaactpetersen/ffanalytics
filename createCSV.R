library(ffa.dbRead)
FFA_MYSQL <- "local_db"
site.config <- projectionsConfig()

for(tbl.name in names(site.config)){
  csv.file <- paste0(tolower(tbl.name), ".csv")
  conf.tbl <- site.config[[tbl.name]]
  if(tbl.name == "siteUrls"){
    conf.tbl[siteID == 12, siteUrl := gsub("u6gk8h2vgyyz", "{$FFNKEY}", siteUrl, fixed = TRUE)]
    conf.tbl[siteID == 2, siteUrl := gsub("/170716/", "/{$YahooLeague}/", siteUrl, fixed = TRUE)]
  }
  if(tbl.name == "sites"){
    conf.tbl[playerIdCol %in% c("fbgId", "fftId"), playerIdCol := NA]
  }
  write.csv(site.config[[tbl.name]],
            file = paste0("data-raw/", csv.file), row.names = FALSE)
}
