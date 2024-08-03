library(RSelenium)
library(rvest)
library(tidyverse)

vignette("basics", package = "RSelenium")

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 32770,
  browserName = "firefox"
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


writeLines(html_source, "pag2.html")


