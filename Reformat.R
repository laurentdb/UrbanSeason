library(tidyr)
library(dplyr)

# Read scores
scores0 <- read.csv("scoresComplet.csv", na.strings="", stringsAsFactors = FALSE, fileEncoding="UTF-8")
scores0$Date<- as.Date(scores0$Date, format="%d/%m/%Y")

data <- separate(scores0, Score, c("Score_E1","Score_E2"))
data$Score_E1 <- as.numeric(data$Score_E1)
data$Score_E2 <- as.numeric(data$Score_E2)
data <- separate(data, Equipe1, paste0("E1_J",1:5),sep="[ ]+")
data <- separate(data, Equipe2, paste0("E2_J",1:5),sep="[ ]+")

data <- data %>% mutate(goalDiff=Score_E1-Score_E2)
data <- tidyr::gather(data, Equipe, Nom, 4:13 ) 
data$Equipe <- gsub("_J.","", data$Equipe)

data$GoalM <- (data$Score_E1*(data$Equipe=="E1")+data$Score_E2*(data$Equipe=="E2"))
data$GoalE <- (data$Score_E2*(data$Equipe=="E1")+data$Score_E1*(data$Equipe=="E2"))
data$GoalDiff <- (data$Score_E1-data$Score_E2)*(1*(data$Equipe=="E1")-1*(data$Equipe=="E2"))
data <- data %>% mutate(Gagne = 1*(GoalDiff>0), Perdu = 1*(GoalDiff<0), Nul = 1*(GoalDiff==0), Points = 3*Gagne+Nul)

summary <- data %>% group_by(Nom) %>% arrange(Date) %>% mutate(Pts=cumsum(Points), m =cumsum(GoalM), e =cumsum(GoalE), Diff =cumsum(GoalDiff), G = cumsum(Gagne), P = cumsum(Perdu), N = cumsum(Nul), J =G+P+N)
maxGD <- max(max(summary$Diff),-min(summary$Diff))
summary <- summary %>% mutate(Score=Pts+Diff/(10*maxGD))

view <- summary %>% filter(Date==max(Date)) %>% filter(Nom!="") %>% ungroup %>% mutate(Rang = rank(-Score,ties.method="min")) %>% 
  select(Rang, Nom, Pts, J, G, N, P, m, e, Diff, Score) %>%
  mutate(pcG = paste0(format(100*G/J,digits=0),"%"), pcN = paste0(format(100*N/J,digits=0),"%"), pcP = paste0(format(100*P/J,digits=0),"%"), mpm = format(m/J,digits=2), epm = format(e/J,digits=2), ppm=Pts/J) %>%
#  select(Rang, Nom, Pts, J, G, N, P, m, e, Diff, FinalScore, pcP=pcWin, pcN=pcDraw, pcP=pcLose) %>% 
  arrange(Rang)

printColumns <- c("Rang"="Rang", "Nom"="Nom", "Points (Pts)"="Pts", "Joués (J)" = "J", "Gagnés (G)"="G", "Nuls (N)"="N", "Perdus (P)"="P", "Buts marqués (m)"="m", "Buts encaissés (e)"= "e", "Différence de buts (Diff)"="Diff", "Score (Pts+Diff/(10*max(Diff))" = "Score", "% Gagnés (pcG)"="pcG","% Nuls (pcN)"="pcN", "% Perdus (pcP)"="pcP", "Buts marqués par match (mpm)"="mpm", "Buts encaissés par match (epm)"="epm", "Points par match (ppm)"="ppm")
viewColumns = colnames(view)

# write.csv(summary, "../csv/summary.csv",row.names=FALSE)

