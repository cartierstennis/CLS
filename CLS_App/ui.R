# CLS - shint server #

# This script wrap up all R objects into HTML#

# Last edit on 2/1/2016 by Mark Li #


# Package Loading # [1]
#install.packages("shiny")
library(shiny)
#install.packages("dplyr")
library(dplyr)



shinyUI(fluidPage(
  titlePanel("CLS Manager Dashbroad"),

  sidebarLayout(
    sidebarPanel(
    	img(src = "twitter_logo.png", height = 100, width = 100, align = "center"),
    	br(),
        uiOutput("clas_active"),
        uiOutput("Study_Type"),
        uiOutput("conversion_type"),
        uiOutput("attribution_window"),
        dateRangeInput("dates", label = h6("* Please Choose the Start Date and End Date"),
                                 start = Sys.Date() - 8, end = Sys.Date()) # -- Can be extend once hosting on larger machine

    	),




    mainPanel(
         h4("Conversion Lift Study - Views", align = "top"),
         br(),
         tabsetPanel(
             tabPanel("* Cumulative Advertiser Growth Trend",
                      plotOutput("plot1"),
                      tableOutput("plot2"),
                      downloadButton(outputId = "down", label = "Download the plot in PDF"))
             # tabPanel("* Adoption Summary",
             #          dataTableOutput("mytable3")),
             # tabPanel("Line-item View - By Lineitem",
             #          dataTableOutput("mytable3")),
             # tabPanel("Line-item View - By Lineitem",
             #          dataTableOutput("mytable3")),
             # tabPanel("Line-item View - By Lineitem",
             #          dataTableOutput("mytable3")),
             # tabPanel("Line-item View - By Lineitem",
             #          dataTableOutput("mytable3"))   


         	)
    	)
  )
))









