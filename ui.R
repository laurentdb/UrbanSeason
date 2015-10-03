library(shiny)

# Load the ggplot2 package which provides
# the 'mpg' dataset.
library(ggplot2)
source("CompileScores.R")

# Define the overall UI
shinyUI(
  fluidPage(
    titlePanel("2015-2016 Urban Season"),
    
    tabsetPanel(type = "tabs", 
      tabPanel("Leaderboard",
               sidebarPanel(
                 checkboxGroupInput('show_columns', 'Tick columns to show:',
                                    colnames(view), 
                                    selected = colnames(view)))
               ,
               mainPanel(
                 dataTableOutput("leaderboard")
               )
      )
      ,
      tabPanel("Graphical view", 
               sidebarPanel(
                 radioButtons("radioView", label = h4("Select your view:"),
                              choices = list("Number of points" = 1, "Goal difference" = 2, "Final score" = 3), 
                              selected = 1),
                 hr()
                 ,
                 checkboxGroupInput('show_players', 'Tick players to show:',
                                   unique(points$Name), 
                                   selected = unique(points$Name)))
               ,
               mainPanel(
                 plotOutput("plot")
               )
      )
    )
  )
)