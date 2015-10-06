library(shiny)

# Load the ggplot2 package which provides
# the 'mpg' dataset.
library(ggplot2)

#source("Reformat.R")

# Define a server for the Shiny app
shinyServer(function(input, output) {
  
  # Filter data based on selections
  output$leaderboard <- renderDataTable({
    myview <- view[,colnames(view) %in% input$show_columns]
    myview
  })
  
  output$plot <- renderPlot({
    if(input$radioView==1)
    {
      g<-ggplot(summary[summary$Name%in%input$show_players,], aes(Date, TotalPoints, color=Name))   +geom_line()+geom_point()+labs(y="Number of points")
    }
    else if(input$radioView==2)
    {  
      g<-ggplot(summary[summary$Name%in%input$show_players,], aes(Date, TotalGoal, color=Name))        +geom_line()+geom_point()+labs(y="Goal difference")
    }
    else if(input$radioView==3)
    {
      g<-ggplot(summary[summary$Name%in%input$show_players,], aes(Date, FinalScore, color=Name))+geom_line()+geom_point()
    }
    g
  })
  
  # Filter data based on selections
  output$scores <- renderDataTable({
    myview <- scores0[,colnames(scores0) %in% input$show_columns2]
    myview
  })
  
  
})