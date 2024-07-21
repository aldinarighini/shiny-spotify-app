library(shiny)

ui <- fluidPage(
  titlePanel("Spotify Artist Comparison"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("artist1", "Select Artist 1:", choices = NULL),
      selectInput("artist2", "Select Artist 2:", choices = NULL)
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Spotify Streams Comparison", plotOutput("stream_comp")),
        tabPanel("Total Number of Songs", plotOutput("total_songs_comp")),
        tabPanel("Feature Comparison Across All Songs", plotOutput("feature_comp"))
      )
    )
  )
)
