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
db.links <- db.links |> filter(Country == 'United States')
db.links <- db.links[1:3, ]

#---Selenium Server----
vignette("basics", package = "RSelenium")

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 32799,
  browserName = "firefox"
)
remDr$open()
remDr$getStatus()

func.total <- function(Link){
  print(paste0("Conteo: ",Link))
  remDr$navigate(Link)
  html_source <- remDr$getPageSource()[[1]]
  writeLines(html_source, "pagveamos.html")
  doc <- read_html(html_source, encoding = "UTF-8")
  
  quintil <- list(doc |> html_elements(xpath = '//div/div[@class="element__details"]/small') |> 
                    html_text2())
  
  caracteristicas <- doc |> html_elements(xpath = '//ul[@class="list list--lipper"]/li/span') |>
                  html_text2()
  
  categoria.table <- doc |> html_elements(xpath = '//div/table/tbody/tr/td[@class="table__cell w50 u-semi"]') |>
                  html_text2()
  
  lista <- list(quintil = quintil, 
                caracteristicas = caracteristicas,
                categoria = categoria.table
  )
  html_source
}

html_veamos <- func.total('https://www.marketwatch.com/investing/Fund/SPDV?countryCode=US')
doc2 <- read_html(html_veamos, encoding = "UTF-8")
quintil2 <- (doc2 |> html_elements(xpath = '//div/div[@class="element__details"]/small') |> 
                  html_text2())

db.scraping <- db.links |>
  rowwise() |>
  mutate(resultado = list("hola")) |>
  ungroup()

write_xlsx(db.scraping, "./scrapy/bdTotal.xlsx")





wi <- read_html("AAM.html", encoding = "UTF-8")
qui <- wi |> html_elements(xpath = '//div/div[@class="element__details"]') |> 
  html_text2()

caracteristicas <- wi |> html_elements(xpath = '//ul[@class="list list--lipper"]/li/span') |>
  html_text2()

categoria.table <- wi |> html_elements(xpath = '//div/table/tbody/tr/td[@class="table__cell w50 u-semi"]') |>
  html_text2()

listawi <- list(quintil = qui, 
              caracteristicas = caracteristicas,
              categoria = categoria.table
)

db.listawi <- tibble(
  Informacion = character(),
)
db.listawi <- db.listawi %>% add_row()

db.listawi <- db.listawi |> mutate(Informacion = list(listawi))


