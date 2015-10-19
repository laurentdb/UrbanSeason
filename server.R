library(shiny)

# Load the ggplot2 package which provides
# the 'mpg' dataset.
library(ggplot2)

#source("Reformat.R")

# Define a server for the Shiny app
shinyServer(function(input, output, session) {
  
  # Filter data based on selections
  output$leaderboard <- renderDataTable({
    myview <- view[,colnames(view) %in% input$show_columns]
    myview
  })
  
  myChoices = unique(summary$Nom)
  
  observe({
   updateCheckboxGroupInput(
      session, 'show_players', choices = myChoices,
      selected = if (input$bar) myChoices
    )
  })
  
  output$plot <- renderPlot({
    if(input$radioView==1)
    {
      g<-ggplot(summary[summary$Nom%in%input$show_players,], aes(Date, Pts, color=Nom)) +geom_line()+geom_point()+labs(y="Nombre of points")
    }
    else if(input$radioView==2)
    {  
      g<-ggplot(summary[summary$Nom%in%input$show_players,], aes(Date, Diff, color=Nom)) +geom_line()+geom_point()+labs(y="Difference de buts")
    }
    else if(input$radioView==3)
    {
      g<-ggplot(summary[summary$Nom%in%input$show_players,], aes(Date, Score, color=Nom))+geom_line()+geom_point()+labs(y="Score final = Points + Diff.buts/(10*max(Diff.buts))")
    }
    g
  })
  
  # Filter data based on selections
  output$scores <- renderDataTable({
    myview <- scores0[,colnames(scores0) %in% input$show_columns2]
    myview
  })
  
  # Filter data based on selections
  output$detailedscores <- renderDataTable({
    mytable <- summary
    mytable
  })
  
  
  # Team creation
  JoueursPresents <- reactive({
    mydata <- view %>% filter(Nom %in% input$team_players)
    if(input$radioCriteria==1)
      mydata <- arrange(mydata, desc(Score))
    else if(input$radioCriteria==2)
      mydata <- arrange(mydata, desc(mpm), desc(Score))
    else if(input$radioCriteria==3)
      mydata <- arrange(mydata, epm, desc(Score))
    mydata
  })
  
  standardSelection <- c(1,2,2,1,1,2,2,1,1,2)
  mySelection <- reactive({
    
    input$RunButton # Create a dependency on the action button
    if(input$NbFixed==0)
    {
      res <- sample(standardSelection,10,replace=FALSE)
    }
    else if(input$NbFixed>=9)
    {
      res <- standardSelection
    }
    else {
      fixed <- standardSelection[1:input$NbFixed]
      alea <- standardSelection[(input$NbFixed+1):10]
      res<-c(fixed, sample(alea,length(alea),replace=FALSE))
    }
    res
  })
  
  Equipe1 <- reactive({
    validate(
      need(nrow(JoueursPresents()) == 10, "Choisissez 10 joueurs exactement!")
    )
    Equipe1 <- JoueursPresents()$Nom[mySelection()==1]
  })
  
  Force1 <- reactive({
    if(input$radioCriteria==1)
      x <- JoueursPresents()$Score 
    else if(input$radioCriteria==2)
      x <- JoueursPresents()$mpm 
    else if(input$radioCriteria==3)
      x <- JoueursPresents()$epm
    sum(as.numeric(x[JoueursPresents()$Nom %in% Equipe1()]))
  })
  
  Equipe2 <- reactive({
    validate(
      need(nrow(JoueursPresents()) == 10, "Choisissez 10 joueurs exactement!")
    )
    Equipe1 <- JoueursPresents()$Nom[mySelection()==2]
  })
  
  Force2 <- reactive({
    if(input$radioCriteria==1)
      x <- JoueursPresents()$Score 
    else if(input$radioCriteria==2)
      x <- JoueursPresents()$mpm 
    else if(input$radioCriteria==3)
      x <- JoueursPresents()$epm
    sum(as.numeric(x[JoueursPresents()$Nom %in% Equipe2()]))
  })
  
  output$E1 <- renderText(paste(Equipe1(), "\n"))
  output$F1 <- renderText(paste("Force=", Force1()))
  output$E2 <- renderText(gsub(" ", "\n", paste(Equipe2())))
  output$F2 <- renderText(paste("Force=", Force2()))
  output$ErrorMessage <- renderText(
    if(nrow(JoueursPresents())<10)
      "Pas assez de joueurs!"
    else if(nrow(JoueursPresents())>10)
       "Trop de joueurs!"
    else ""
  )
})