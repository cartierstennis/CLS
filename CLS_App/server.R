# CLS - shint server #

# This script summarize tables and views for CLS report #

# Last edit on 2/1/2016 by Mark Li #


# Package Loading # [1]
#install.packages("shiny")
library(shiny)
#install.packages("dplyr")
library(dplyr)
#install.packages("ggplot2")
library(ggplot2)

# Call out simple functions # [2]



# Shiny server function # [4]
shinyServer(function(input, output) {

    # Loading raw data
      data.roi <- read.csv("/Users/mli/Desktop/Team_Projects_Twitter/Cartier/CLS_App/data/sample_roi_prod.csv", 
                           header = TRUE, stringsAsFactors = FALSE,
                           colClasses=c("Date", "character", "character", rep("integer",3), "character", rep("integer",2)))
      data.ad <- read.csv("/Users/mli/Desktop/Team_Projects_Twitter/Cartier/CLS_App/data/sample_ad_prod.csv", 
                          header = TRUE, stringsAsFactors = FALSE,
                          colClasses=c(rep("character",4), "Date", rep("character",5)))
    

    # Creating filter parameters

    # -- 'Active Status'
    cls_active <- unique(data.ad$cls_is_active)
    output$clas_active <- renderUI({
      checkboxGroupInput(inputId = "activity", h6("* Please Choose whether CLS Study Activated"), cls_active, selected = "Yes")
      })

    # -- 'Study Type'
    study_type <- unique(data.roi$study_type)
    output$Study_Type <- renderUI({
    selectInput(inputId = 'study_type', h6("* Please Choose an Study Type"), as.list(study_type), selected = 1)
    })

    # -- 'Conversion Type'
    conversion_type <- unique(data.roi$conversion_type)
    output$conversion_type <- renderUI({
    selectInput(inputId = 'conversion_type', h6("* Please Choose an Conversion Type"), as.list(conversion_type), selected = 2)
    })

    # -- 'Time Range'
    # {BUilt in ui phase}

    # -- 'Attribution Window'
    Attribution_Window <- sort(unique(data.roi$attribution_window))
    output$attribution_window <- renderUI({
    selectInput(inputId = 'attribution_window', h6("* Please Choose an Attribution Window"), as.list(Attribution_Window), selected = 7)
    })


    # processing data (General)
    # -- advertiser level activity var (plot1)
    

    # -- Generate 'Group_Type' (plot2) ** Potentially we should do this in SQL when live connected **



    # -- Plot1 processing
    culumlative_adoption_plot <- function() {
                    plot.data <- data.ad %>%
                                 filter(cls_is_active == input$activity) %>%
                                 mutate(new_date = format(campaign_start_date, "%Y-%m")) %>%
                                 group_by(new_date) %>%
                                 summarize(advertiser_count = length(unique(account_id))) %>%
                                 arrange(new_date)
                    plot.data <- as.data.frame(plot.data) # proccess plot data
  
                    plot.trend <- ggplot(plot.data, aes(x=1:nrow(plot.data), y=cumsum(advertiser_count))) + geom_line() + geom_point() +
                                  geom_text(aes(label = cumsum(advertiser_count)), hjust = 2) +
                                  theme(axis.text.x = element_text(angle=45, hjust = 1)) +
                                  scale_x_discrete(labels = plot.data$new_date) + xlab("Date") + ylab("Cumulative_account_growth") # plot data
  
       return (plot.trend)
    }
     
    # -- Plot2 processing               
    Adoption_Summary <- function () {
                    summary.data <- data.ad %>%
                                    group_by(cls_is_active) %>%
                                    summarize(Count = length(unique(account_id))) %>%
                                    rename(Status = cls_is_active)
                    summary.data$Status <- ifelse(summary.data$Status == "Yes", "Active", "Inactive") 
                    summary.data <- rbind(summary.data, c("Total", colSums(summary.data[,2])))
       return (summary.data)
    }

    
    # -- Plot3 processing 
    Performance_Summary_Snapshot <- function () {
                     
                    
                   



                    










    }

    # -- Plot4 processing 
    Time_series_view_cumulative <- function () {












    }


    # -- Plot5 processing 
    Time_series_view_incremental_daily <- function () {














    }


    # -- Plot6 processing 
    Advertiser_level_performance_ranking <- function () {












    }






    # Final Views Section

     output$plot1 <- renderPlot({ 
         culumlative_adoption_plot()
     })

     output$down <- downloadHandler(
      # specify the file name
        filename = function() {
              "Cumulative_advertiser_plot(CLS).pdf"
          },
        # Write the plot back
        content = function(file){
              pdf(file)
              culumlative_adoption_plot()
              dev.off()
        }
      )

     output$plot2 <- renderTable({ 
          Adoption_Summary()
     })




  }
)




























