library(shiny)

# Load the ggplot2 package which provides
# the 'mpg' dataset.
library(ggplot2)

source("CompileScores.R")

# Define a server for the Shiny app
shinyServer(function(input, output) {
  
  # Filter data based on selections
  output$leaderboard <- renderDataTable({
    data <- view[,colnames(view) %in% input$show_columns]
    data
  })
  
  output$plot <- renderPlot({
    if(input$radioView==1)
    {
      data <- points
      g<-ggplot(data[data$Name%in%input$show_players,], aes(Date, Score, color=Name))   +geom_line()+geom_point()+labs(y="Number of points")
    }
    else if(input$radioView==2)
    {  
      data <- goalDiff
      g<-ggplot(data[data$Name%in%input$show_players,], aes(Date, GoalDiff, color=Name))        +geom_line()+geom_point()+labs(y="Goal difference")
    }
    else if(input$radioView==3)
    {
      data <- finalScore
      g<-ggplot(data[data$Name%in%input$show_players,], aes(Date, Score, color=Name))+geom_line()+geom_point()
    }
    g
  })
  
  
})