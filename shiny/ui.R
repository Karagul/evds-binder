#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Old Faithful Geyser Data"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      passwordInput("evds_api_key","EVDS_API_KEY","",placeholder="Enter your key here."),
      textInput("evds_query_data","Query Series","TP.AB.A13",placeholder="TP.AB.A13"),
      dateRangeInput("evds_date_range","Date Range",start="2019-01-01",end=lubridate::today()),
      actionButton("evds_query","Get Data",icon=icon("check"),class="btn btn-primary"),
      # downloadButton("evds_data_download","Download Data",icon=icon("download"),class="btn btn-success"),
      uiOutput("download_button_ui"),
      tags$hr(),
      tags$h2("Açık Piyasa Repo İşlemleri"),
      downloadButton("acik_piyasa_repo","Açık Piyasa - Repo Tablosu",icon=icon("download"),class="btn btn-success")
    ),

    # Show a plot of the generated distribution
    mainPanel(
       textOutput("query_url"),
       dataTableOutput("query_data")
    )
  )
))
