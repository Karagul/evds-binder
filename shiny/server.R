
library(shiny)
library(rvest)
library(tidyverse)
library(lubridate)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  rv <- reactiveValues(
    call_url = NULL,
    evds_df = tibble()
  )

  output$query_url <- renderText({

    if(is.null(rv$call_url)){
      return("Enter your key, select a series and get your data below")
    }

    if(nrow(rv$evds_df) == 0){
      if(input$evds_api_key==""){
        return(paste0("NO API KEY - ADD KEY: ",rv$call_url))
      }
      return(paste0("NO DATA RETURNED - CHECK URL OR KEY: ",rv$call_url))
    }

    rv$call_url

  })

  observeEvent(input$evds_query,{
    rv$call_url <- paste0("https://evds2.tcmb.gov.tr/service/evds/series=",input$evds_query_data,"&startDate=",format(input$evds_date_range[1],format="%d-%m-%Y"),"&endDate=",format(input$evds_date_range[2],format="%d-%m-%Y"),"&type=json&key=")

    if(input$evds_api_key==""){
      return(NULL)
    }

    print(rv$call_url)

    the_phrase <- paste0(rv$call_url,input$evds_api_key)

    the_response <- httr::GET(the_phrase)

    json_content<-
    httr::content(the_response,as="text",encoding="UTF-8")

    if(json_content != ""){
      rv$evds_df <- jsonlite::fromJSON(json_content,flatten=TRUE)$items
    }else{
      rv$evds_df <- tibble()
    }

    #print(rv$evds_df)
  })

  output$query_data <- renderDataTable({

    rv$evds_df

  })

  output$download_button_ui <- renderUI({

    if(nrow(rv$evds_df) > 0){
      the_output_ui <- downloadButton("evds_data_download","Download Data",icon=icon("download"),class="btn btn-success")
    }else{
      the_output_ui <- tags$br()
    }

    tagList(
      the_output_ui
    )

  })

  # eventReactive(input$acik_piyasa_repo,{
  #   mypg <- read_html("https://www.tcmb.gov.tr/wps/wcm/connect/tr/tcmb+tr/main+page+site+area/acik+piyasa+islemleri/ihale+ile+gerceklestirilen+repo+islemleri+verileri")
  #   datatables <- mypg %>% html_table()
  #
  # })

  output$evds_data_download <- downloadHandler(
    filename = function(){
      paste("evds_data.xlsx", sep="")
    },
    content = function(con){
      # Create a Progress object
      progress2 <- shiny::Progress$new()
      # Make sure it closes when we exit this reactive, even if there's an error
      on.exit(progress2$close())
      progress2$inc(0.1, detail = paste("Checking Data"))
      the_df <- rv$evds_df
      openxlsx::write.xlsx(the_df,con)
    }
  )

  output$acik_piyasa_repo <- downloadHandler(
    filename = function(){
      paste('tcmb-acik-piyasa-ihale-repo.xlsx', sep='')
    },
    content = function(con){
      # Create a Progress object
      progress <- shiny::Progress$new()
      # Make sure it closes when we exit this reactive, even if there's an error
      on.exit(progress$close())
      progress$inc(0.1, detail = paste("Reaching page"))
      mypg <- read_html("https://www.tcmb.gov.tr/wps/wcm/connect/tr/tcmb+tr/main+page+site+area/acik+piyasa+islemleri/ihale+ile+gerceklestirilen+repo+islemleri+verileri")

      progress$inc(0.3, detail = paste("Preparing Table"))

      datatables <- mypg %>% html_table()
      mydf <- datatables[[1]] %>% slice(-(1:7)) %>% tbl_df()

      colnames(mydf) <- c("AUCTION NO","TRANSACTION DATE","AUCTION TYPE","VALUE DATE","MATURITY DATE","DTM","AMOUNT OFFERED","AMOUNT ACCEPTED","MINIMUM SIMPLE RATE","AVERAGE SIMPLE RATE","MAXIMUM SIMPLE RATE","MINIMUM COMPOUND RATE","AVERAGE COMPOUND RATE","MAXIMUM COMPOUND RATE")

      progress$inc(0.5, detail = paste("Writing to Excel"))
      openxlsx::write.xlsx(mydf, con)
    }
  )
})
