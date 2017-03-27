library(shiny)

# Load the ggplot2 package which provides
# the 'mpg' dataset.
library(ggplot2)
source("Reformat.R")
JoueursFrequents0 <- head(arrange(view,desc(J))$Nom,10)

# Define the overall UI
shinyUI(
  fluidPage(
    titlePanel("2016-2017 Urban Season"),
    
    tabsetPanel(type = "tabs", 
      tabPanel("Classement",
               sidebarPanel(
                 sliderInput("min_match", "Nombre de matchs joués", 0, 45, c(4,45), step = NULL, round = FALSE, ticks = TRUE, animate = FALSE),
                 checkboxGroupInput('show_columns', 'Colonnes à afficher:',
                                    printColumns, 
                                    selected = printColumns))
               ,
               mainPanel(
                 dataTableOutput("leaderboard")
               )
      )
      ,
      tabPanel("Vue graphique", 
                 sidebarPanel(
                 radioButtons("radioView", label = h4("Choisissez la vue:"),
                              choices = list("Nombre de points" = 1, "Différence de buts" = 2, "Score" = 3), 
                              selected = 1),
                 hr()
                 ,
                 h4('Joueurs à afficher:'),
                 checkboxInput('bar', 'Tous/Aucun', value=1)
                 ,
                 hr()
                 ,
                 checkboxGroupInput('show_players', '',
                                   unique(summary$Nom)
                                   )
                 
               ),
               mainPanel(
                 plotOutput("plot")
               )
        )
      ,
      tabPanel("Résumé des matchs",
               sidebarPanel(
                 checkboxGroupInput('show_columns2', 'Colonnes à afficher:',
                                    colnames(scores0), 
                                    selected = colnames(scores0)))
               ,
               mainPanel(
                 dataTableOutput("scores")
               )
      )
      ,tabPanel("Créateur d'équipe", 
                sidebarPanel(
                  hr(),
                  actionButton("RunButton", "Composer les équipes",icon("random")),
                  hr(),
                  h4("Partie déterministe:"),
                  radioButtons("radioCriteria", label = h5("Critère de sélection:"),
                               choices = list("Nombres de points" =1, "Points par match" = 2, "Buts marqués" = 3, "Buts encaissés" = 4), 
                               selected = 1)
                  ,numericInput("NbFixed", "Joueurs choisis selon critère", value=6, min=0, max=10)
                ),
                mainPanel(
                  column(4,
                         h4('Joueurs présents:'),
                         checkboxGroupInput('team_players', '',
                                            unique(summary$Nom),
                                            selected = JoueursFrequents0
                         )
                  )
                  ,
                  column(6,
                         h4("Equipe 1"),
                         textOutput("E1"),
                         textOutput("F1"),
                         hr(),
                         h4("Equipe 2"),
                         textOutput("E2"),
                         textOutput("F2"),
                         hr(),
                         textOutput("ErrorMessage")
                  )
                )
      )
    #  ,tabPanel("Résultats détaillés",
    #            mainPanel(dataTableOutput("detailedscores")))
    )
  )
)