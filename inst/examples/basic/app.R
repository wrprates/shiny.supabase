# Basic Example - shiny.supabase
# This example shows basic usage with user information

library(shiny)
library(shiny.supabase)

# Configure Supabase client
client <- supabase_client(
  url = "https://your-project.supabase.co",
  key = "your-anon-key"
)

# UI - function that returns protected content
protected_ui <- function(request) {
  fluidPage(
    titlePanel("Basic App with Supabase"),

    sidebarLayout(
      sidebarPanel(
        h4("Menu"),
        p("You are logged in!"),
        br(),
        supabase_logout_ui("logout", "Sign Out")
      ),

      mainPanel(
        h3("Protected Area"),
        p("This content is only visible to authenticated users."),

        fluidRow(
          column(6,
            wellPanel(
              h4("User Information"),
              verbatimTextOutput("user_data")
            )
          ),
          column(6,
            wellPanel(
              h4("Session Status"),
              textOutput("session_status")
            )
          )
        )
      )
    )
  )
}

# Server - function containing protected logic
protected_server <- function(input, output, session, user_state) {

  # Configure logout
  user_state <- supabase_logout_server("logout", client, user_state)

  # Show user data
  output$user_data <- renderText({
    current_user <- user_state()
    if (current_user$authenticated && !is.null(current_user$user)) {
      paste(
        "Email:", current_user$user$email, "\n",
        "ID:", current_user$user$id, "\n",
        "Created:", current_user$user$created_at
      )
    } else {
      "User not authenticated"
    }
  })

  # Session status
  output$session_status <- renderText({
    current_user <- user_state()
    if (current_user$authenticated) {
      "✅ Active session"
    } else {
      "❌ Inactive session"
    }
  })
}

# Use protection wrappers
ui <- require_auth(protected_ui, client, "Login Required")
server <- auth_server_guard(client, protected_server)

# Run app
shinyApp(ui, server)