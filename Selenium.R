library(RSelenium)
library(rvest)
library(tidyverse)
library(htmltools)

vignette("basics", package = "RSelenium")

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 32769,
  browserName = "chrome",
)

remDr$open()
remDr$getStatus()

remDr$navigate("https://www.marketwatch.com/tools/markets/exchange-traded-funds/a-z/A/1")

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


writeLines(html_source, "pag3.html")



remDr$navigate("https://www.trackinsight.com/en/fund/SMH")
remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
Sys.sleep(runif(1, min = 2, max = 8)) 
html_source2 <- remDr$getPageSource()[[1]]
writeLines(html_source2, "pag4.html")

remDr$close()