#' Reverse Last and First Name
#'
#' Takes an input string in the form of "Last Name, First Name" and converts it
#' to "First Name Last Name".
#' @examples firstLast("Smith, John") # Will return John Smith
#' @param lastFist A string with the name to be converted
#' @export firstLast
firstLast <- function(lastFirst){
  nameMatrix <- matrix(unlist(strsplit(lastFirst, ", ")), ncol =2, byrow = TRUE)
  fullName <- paste(nameMatrix[,2], nameMatrix[,1])
  return(fullName)
}


#' Set tiers based on thresholds
#' @export setTier
setTier <- function(points, position){
  threshold <- scoreThreshold[position]
  if(is.na(threshold))
    threshold <- 20
  tiers <- rep(as.numeric(NA), length(points))
  tierNum <- 1
  points.order <- order(-points)
  points <- points[points.order]
  repeat{
    tiers[points >= floor(max(points[is.na(tiers)]) - threshold) & is.na(tiers)] <- tierNum

    if(all(!is.na(tiers)))
      break
    tierNum <- tierNum + 1
  }
  tiers[points.order] <- tiers
  return(tiers)
}

#' Set tiers based on clusters
#' @export clusterTier
clusterTier <- function(points, position){
  numGroups <- tierGroups[position]
  tier <- numGroups - mclust::Mclust(points, G = numGroups) + 1
  return(tier)
}

#' Calculate Dropoff value
#' @export dropoffValue
dropoffValue <- function(dataValue){
  descend.order = order(-dataValue)
  dataValue <- dataValue[descend.order]

  valueTable <- data.table(c(dataValue[-1], NA), c(dataValue[-c(1,2)], NA, NA))

  dropoff <- valueTable[, rowMeans(.SD, na.rm = TRUE)]
  dropoff[!is.finite(dropoff)] <- NA
  dropoff <- dataValue - dropoff
  dropoff[descend.order] <- dropoff
  return(dropoff)
}

#' @export scrapeXMLdata
scrapeXMLdata <- function(xmlUrl){

  urlSite <- websites[sapply(websites,
                             function(ws)(length(grep(ws, tolower(xmlUrl),
                                                      fixed = TRUE)) >0))]
  if(urlSite == "fantasyfootballnerd"){
    ffn_data <- xml2::xml_children(xml2::read_xml(xmlUrl))
    xmlData  <- data.table::rbindlist(
      lapply(ffn_data, function(p){
        p_tbl <-data.table::as.data.table(xml2::as_list(xml2::xml_contents(xml2::xml_children(p))))
        var_names <- xml2::xml_name(xml2::xml_children(p))
        data.table::setnames(p_tbl, var_names)
        return(p_tbl)
      }), fill = TRUE
    )

  } else {
    xmlData <- as.data.frame(t(XML::xpathSApply(XML::xmlParse(xmlUrl),
                                                "//Player", fun = XML::xmlToList)))
    xmlData <- as.data.frame(apply(xmlData, 2, unlist))
  }
  return(xmlData)

}
