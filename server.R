library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)

# Load the cleaned data
data <- read.csv("cleaned_spotify_data.csv", stringsAsFactors = FALSE)

server <- function(input, output, session) {
  # Check if data is loaded correctly
  observe({
    if (is.null(data) || nrow(data) == 0) {
      showNotification("Data not loaded correctly or data is empty.")
    } else {
      artists <- unique(data$artist.s._name)
      if (length(artists) == 0) {
        showNotification("No artists found in the data.")
      } else {
        updateSelectInput(session, "artist1", choices = artists)
        updateSelectInput(session, "artist2", choices = artists)
      }
    }
  })
  
  # Filter data based on selected artists
  artist_data <- reactive({
    req(input$artist1, input$artist2)
    data %>%
      filter(artist.s._name %in% c(input$artist1, input$artist2))
  })
  
  # Stream comparison plot
  output$stream_comp <- renderPlot({
    req(artist_data())
    df <- artist_data() %>%
      group_by(artist.s._name) %>%
      summarize(total_spotify_streams = sum(streams, na.rm = TRUE) / 100000)
    
    ggplot(df, aes(x = artist.s._name, y = total_spotify_streams, fill = artist.s._name)) +
      geom_bar(stat = "identity") +
      labs(title = "Spotify Streams Comparison", x = "Artist", y = "Total Spotify Streams (in 100,000s)") +
      theme_minimal()
  })
  
  # Total number of songs plot
  output$total_songs_comp <- renderPlot({
    req(artist_data())
    df <- artist_data() %>%
      group_by(artist.s._name) %>%
      summarize(total_songs = n())
    
    ggplot(df, aes(x = artist.s._name, y = total_songs, fill = artist.s._name)) +
      geom_bar(stat = "identity") +
      labs(title = "Total Number of Songs", x = "Artist", y = "Total Songs") +
      theme_minimal()
  })
  
  # Features comparison plot
  output$feature_comp <- renderPlot({
    req(input$artist1, input$artist2)
    
    features_data <- artist_data() %>%
      select(artist.s._name, danceability_., valence_., energy_., acousticness_., instrumentalness_., liveness_., speechiness_.) %>%
      pivot_longer(cols = danceability_.:speechiness_., names_to = "feature", values_to = "value")
    
    ggplot(features_data, aes(x = feature, y = value, fill = artist.s._name)) +
      geom_boxplot() +
      labs(title = "Feature Comparison Across All Songs", x = "Feature", y = "Value", fill = "Artist") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
}

shinyApp(ui = ui, server = server)
