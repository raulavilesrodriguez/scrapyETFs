library(tidyverse)
library(rvest)
library(httr)
library(readxl)
library(writexl)
library(stringr)
library(purrr) # to split strings
library(hrbrthemes)
library(viridis) # pallette of colors
library(viridisLite) # pallette of colors
library(RSelenium) # to scrapy with Selenium Server

db.links <- read_excel("./scrapy/linksTotales.xlsx")

#---Selenium Server----
vignette("basics", package = "RSelenium")

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 32769,
  browserName = "firefox"
)

remDr$open()
remDr$getStatus()

func.total <- function(Link){
  print(Link)
  remDr$navigate(Link)
  html_source <- remDr$getPageSource()[[1]]
  doc <- read_html(html_source, encoding = "UTF-8")
  
  quintil <- doc |> html_elements(xpath = '//div/div[@class="element__details"]') |> 
                  html_text2()
  
  caracteristicas <- doc |> html_elements(xpath = '//ul[@class="list list--lipper"]/li/span') |>
                  html_text2()
  
  categoria.table <- doc |> html_elements(xpath = '//div/table/tbody/tr/td[@class="table__cell w50 u-semi"]') |>
                  html_text2()
  
  lista <- list(quintil = quintil, 
                caracteristicas = caracteristicas,
                categoria = categoria.table
  )
  lista
}

db.links <- db.links |>
  rowwise() |>
  mutate(resultado = list(func.total(Link))) |>
  ungroup()


