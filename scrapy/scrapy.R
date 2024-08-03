library(tidyverse)
library(rvest)
library(httr)
library(readxl)
library(stringr)
library(purrr) # to split strings
library(hrbrthemes)
library(viridis) # pallette of colors
library(viridisLite) # pallette of colors
library(RSelenium) # to scrapy with Selenium Server


#______SCRAPY WEB_______
# Algoritm to download all pages
set.seed(1)

url <- paste0("https://www.marketwatch.com/tools/markets/exchange-traded-funds/a-z/A/1")

data.general <- tibble(LETTERS)
padding <- c(6,4,4,2,2,6,5,5,23,2,2,9,3,2,1,3,1,2,8,2,5,5,5,5,1,1)
data.general$padding <- padding


#---Selenium Server----
vignette("basics", package = "RSelenium")

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 32770,
  browserName = "firefox"
)

remDr$open()
remDr$getStatus()

#---initial tibble---
db.links <- tibble(
  Name = character(),
  Country = character(),
  Exchange = character(),
  Sector = character(),
  Link = character()
)

#---scraping -------
apply(data.general, 1, function(x){
  n <- 0
  while(n<as.numeric(x[["padding"]])){
    n <- n + 1
    link <- paste0("https://www.marketwatch.com/tools/markets/exchange-traded-funds/a-z/", x[["LETTERS"]], "/",n)
    print(link)
    remDr$navigate(link)
    html_source <- remDr$getPageSource()[[1]]
    doc <- read_html(html_source, encoding = "UTF-8")
    tabla <- doc |> html_elements(xpath = '//table') |> html_table()
    links <- list(doc |> html_elements(xpath = "//table/tbody/tr/td/a") |> html_attr("href"))
    df.tabla <- tibble(
      unlist(tabla[[1]][1]),
      unlist(tabla[[1]][2]),
      unlist(tabla[[1]][3]),
      unlist(tabla[[1]][4]),
      unlist(links)
    )
    db.links <- rbind(db.links, df.tabla)
  }
})



