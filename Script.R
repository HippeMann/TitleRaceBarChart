library(tidyverse)
library(gganimate)
library(ggimage)

competition.names <- c(
  'Spain-LaLiga' = 'La Liga',
  'England-Premier League' = 'Premier League',
  'Italy-Serie A' = 'Serie A',
  'Germany-1. Bundesliga' = 'Bundesliga',
  'France-Ligue 1' = 'Ligue 1',
  'Portugal-Liga Nos' = 'Primeira Liga',
  'Netherlands-Eredivisie' = 'Eredivisie',
  'England-Championship' = 'Championship',
  'Russia-Premier Liga' = 'Premier League',
  'Turkey-Super Lig' = 'Süper Lig',
  'France-Ligue 2' = 'Ligue 2'
)

competition.ids <- c(
  'Spain-LaLiga' = 'ES1',
  'England-Premier League' = 'GB1',
  'Italy-Serie A' = 'IT1',
  'Germany-1. Bundesliga' = 'L1',
  'France-Ligue 1' = 'FR1',
  'Portugal-Liga Nos' = 'PO1',
  'Netherlands-Eredivisie' = 'NL1',
  'England-Championship' = 'GB2',
  'Russia-Premier Liga' = 'RU1',
  'Turkey-Super Lig' = 'TR1',
  'France-Ligue 2' = 'FR2'
)

# Dark green  : 1A7000
# Light Green : 2DBE00
# Dark Blue   : 005770
# Light Blue  : 0094BE
# Orange      : FF911B
# Red         : F03629

qual.colors.list <- list(
  'Spain-LaLiga' = c("4" = "#1A7000", "6" = "#005770", "7" = "#0094BE", "17" = "#F03629"), 
  'England-Premier League' = c("4" = "#1A7000", "6" = "#005770", "7" = "#0094BE", "17" = "#F03629"), 
  'Italy-Serie A' = c("4" = "#1A7000", "5" = "#005770", "6" = "#0094BE","17" = "#F03629"), 
  'Germany-1. Bundesliga' = c("4" = "#1A7000", "6" = "#005770", "7" = "#0094BE", "15" = "#FF911B", "16" = "#F03629"), 
  'France-Ligue 1' = c("3" = "#1A7000",  "4" = "#005770", "17" = "#FF911B", "18" = "#F03629"), 
  'Portugal-Liga Nos' = c("1" = "#1A7000", "2" = "#2DBE00", "3" = "#005770", "5" = "#0094BE", "15" = "#F03629"), 
  'Netherlands-Eredivisie' = c("2" = "#2DBE00", "7" = "#0094BE", "15" = "#FF911B", "17" = "#F03629"), 
  'England-Championship' = c("2" = "#1A7000", "6" = "#2DBE00", "21" = "#F03629"),
  'Russia-Premier Liga' = c("2" = "#1A7000", "3" = "#2DBE00", "4" = "#005770", "6" = "#0094BE", "12" = "#FF911B", "14" = "#F03629"), 
  'Turkey-Super Lig' = c("1" = "#1A7000", "2" = "#2DBE00", "3" = "#005770", "5" = "#0094BE", "15" = "#F03629"), 
  'France-Ligue 2' = c("2" = "#1A7000",  "5" = "#2DBE00", "17" = "#FF911B", "18" = "#F03629")
  
)

competition.number <- 1

competition <- names(competition.ids)[competition.number]
competition.id <- competition.ids[competition.number]
competition.name <- competition.names[competition.number]


#Data ####

#Generate Data
write(competition.id, "comp.txt")
system("python transfermarkt.py")



#Read Data
path <- paste0("Results/", competition, ".csv")
dt <- read.csv(file = path, header = F, stringsAsFactors = F, encoding='utf-8')
colnames(dt) <- c("Matchday", "Rank", "Team", "Games", "Wins", "Draws", "Loss", "GoalsFor", "GoalsAgainst", "GoalAverage", "Points")


#Useful values for the plot
n.teams <- length(unique(dt$Team))
max.matchday <- max(dt$Matchday)
min.points <- min(dt$Points)
max.points <- max(dt$Points)


#Image paths
wd <- getwd()
dt$TeamLogo <- paste0(wd, "/Logos/", competition, "/", dt$Team, '.png')
league.logo <- paste0(wd, "/Logos/", competition, "/", competition, '.png') 

#Colors ####

#Team Colors for bars
team.colors.csv <- read.csv(file="TeamColors.csv", header=T, stringsAsFactors = F)
team.colors <- team.colors.csv[,2]
names(team.colors) <- team.colors.csv[,1]

#Competition colors for vertical qualifications lines
competition.colors <- qual.colors.list[[competition]]
plot.colors <- setNames(rep("#FFFFFF", n.teams), c(as.character(1:n.teams)))
plot.colors[names(competition.colors)] <- competition.colors


#Checks Files
file.exists(league.logo)

if (sum(!file.exists(unique(dt$TeamLogo)))){ # checks if TeamLogo file exists
  unique(dt$TeamLogo)[!file.exists(unique(dt$TeamLogo))]} 

if(sum(!(unique(dt$Team) %in% names(team.colors)))){ #Check if Team is in team.colors
  print(unique(dt$Team)[!(unique(dt$Team) %in% names(team.colors))])}

dir.create('Gifs', showWarnings = FALSE)


#Plot ####
fps <- 30

p <- dt %>% #filter(Matchday == max.matchday) %>%
  ggplot(aes(x = Rank)) +
  geom_bar(aes(y = Points, fill = Team), stat="identity", alpha = 0.8) +
  geom_image(aes(image = TeamLogo, y = Points + 3)) + #Team Logo on top of the bars
  geom_image(image = league.logo, x = n.teams / 2, y = max.points, size = 0.2) + #League Logo at the top center, add + 1 to the x to nudge it for the Bundesliga
  #Vertical "qualification" lines
  geom_vline(xintercept = as.numeric(names(competition.colors)) + 0.5, colour = as.character(competition.colors), alpha = 0.5, size = 1.5) + 
  #Colors
  scale_fill_manual(values = team.colors) + #colors of the bars
  scale_colour_manual(values = plot.colors) + #colors of vertical "qualification" lines
  #Scales
  scale_x_continuous(expand = c(0, 0), limits = c(0, n.teams + 0.5), breaks=seq(1, n.teams, 1)) + 
  scale_y_continuous(expand = c(0, 0), limits = c(0, max.points + 10), breaks = seq(0, max.points, 3)) +
  #Theme
  theme_classic() + 
  theme(legend.position = "none",
        plot.title = element_text(size = 36),
        plot.subtitle = element_text(size = 24),
        axis.title = element_text(size = 22),
        axis.ticks = element_blank()) +
  labs(title = paste('{competition.name} Ranking after matchday {round(frame_time,0)}'),
       subtitle = 'by u/Hippemann') +
  # Animation code
  transition_time(Matchday) +
  ease_aes('cubic-in-out')

print(p, width = 1200, height = 900) #preview (100 frames at 10 fps)

anim_save(paste0("Gifs/", competition, ".gif"), p, nframes = max.matchday * fps, fps = fps, end_pause = fps * 5, width = 1200, height = 900)




#Other Plot (if a team has a point deduction Championship/Serie A) ####

p <- dt %>% #filter(Matchday == max.matchday)
  ggplot(aes(x = Rank)) +
  geom_bar(aes(y = Points, fill = Team), stat="identity", alpha = 0.8) + 
  geom_image(aes(image = TeamLogo, y = ifelse(Points >= 0, Points + 3, Points - 3))) + #Club logo above the bar if the club has positive number of points, else below
  geom_image(image = league.logo, x = n.teams / 2, y = max.points, size = 0.2) + #League Logo at the top center
  #Vertical "qualification" lines done manually so as to not go below y = 0
  annotate('segment', x = 4 + 0.5, xend = 4 + 0.5, colour = "#1A7000", y = 0, yend = max.points + 10, alpha = 0.5, size = 1.5) + 
  annotate('segment', x = 7 + 0.5, xend = 7 + 0.5, colour = "#005770", y = 0, yend = max.points + 10, alpha = 0.5, size = 1.5) + 
  annotate('segment', x = 17 + 0.5, xend = 17 + 0.5, colour = "#F03629", y = 0, yend = max.points + 10, alpha = 0.5, size = 1.5) + 
  #Colors
  scale_fill_manual(values = team.colors) +
  #Scales
  scale_x_continuous(expand = c(0, 0), limits = c(0, n.teams + 0.5), breaks  =seq(1, 24, 1)) + 
  scale_y_continuous(expand = c(0, 0), limits = c(min.points - 10, max.points + 10), breaks = seq(0, max.points, 3)) + 
  #Theme
  theme_classic() + 
  theme(legend.position = "none",
        plot.title = element_text(size = 36),
        plot.subtitle = element_text(size = 28),
        axis.title = element_text(size = 22),
        axis.text.x = element_text(vjust = 46), #This number might need to be tweeked
        axis.ticks = element_blank(),
        axis.title.x = element_text(vjust = 46), #This number might need to be tweeked
        plot.caption = element_text(size = 22),
        axis.line.x = element_blank()) +
  geom_hline(yintercept = 0, size=1) + #Recreate Base line (y=0)
  labs(title=paste('{competition.name} Ranking after matchday {round(frame_time,0)}'),
       subtitle='by u/HippeMann',
       caption='*Chievo docked 3 points') +
  # Animation code
  transition_time(Matchday) +
  ease_aes('cubic-in-out')

print(p, width = 1200, height = 900) #preview (100 frames at 10 fps)

anim_save(paste0("Gifs/", competition, "v2.gif"), p, nframes = max.matchday * fps, fps = fps, end_pause = fps * 5, width = 1200, height = 900)

















