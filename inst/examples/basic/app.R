# Basic Example - shiny.supabase
# This example demonstrates secure server-side authentication with Supabase

library(shiny)
library(shiny.supabase)

# Configure Supabase client
# Replace with your actual Supabase project credentials
client <- supabase_client(
  url = Sys.getenv("SUPABASE_URL", "https://your-project.supabase.co"),
  key = Sys.getenv("SUPABASE_ANON_KEY", "your-anon-key")
)

# UI - function that returns protected content
# This is only rendered server-side when user is authenticated
protected_ui <- function(request) {
  fluidPage(
    titlePanel("Basic App with Supabase Authentication"),

    sidebarLayout(
      sidebarPanel(
        h4("Menu"),
        p("You are securely logged in!"),
        p("All authentication is handled server-side."),
        br(),
        supabase_logout_ui("logout", "Sign Out")
      ),

      mainPanel(
        h3("Protected Area"),
        p("This content is only visible to authenticated users."),
        p("Try opening DevTools - you cannot bypass this authentication!"),

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
              textOutput("session_status"),
              hr(),
              p("Token auto-refresh enabled", style = "color: green; font-size: 12px;")
            )
          )
        )
      )
    )
  )
}

# Server - function containing protected logic
# This receives authenticated user_state from the guard
protected_server <- function(input, output, session, user_state) {

  # Configure logout functionality with page reload
  user_state <- supabase_logout_server("logout", client, user_state, reload_on_logout = TRUE)

  # Show user data (server-side only)
  output$user_data <- renderText({
    current_user <- user_state()

    if (current_user$authenticated && !is.null(current_user$user)) {
      paste(
        "Email:", current_user$user$email, "\n",
        "ID:", current_user$user$id, "\n",
        "Created:", current_user$user$created_at, "\n",
        "Last Validated:", format(current_user$last_validated %||% Sys.time(), "%Y-%m-%d %H:%M:%S")
      )
    } else {
      "User not authenticated"
    }
  })

  # Session status
  output$session_status <- renderText({
    current_user <- user_state()

    if (current_user$authenticated) {
      token_expires <- if (!is.null(current_user$expires_at)) {
        format(as.POSIXct(current_user$expires_at, origin = "1970-01-01"), "%Y-%m-%d %H:%M:%S")
      } else {
        "Unknown"
      }

      paste0(
        "✅ Active session\n",
        "Token expires: ", token_expires
      )
    } else {
      "❌ Inactive session"
    }
  })
}

# Use secure authentication wrappers
# All auth logic is server-side - no client-side state exposure
ui <- require_auth(protected_ui, client, "Secure Login Required")
server <- auth_server_guard(
  client,
  protected_server,
  ui_function = protected_ui,
  login_title = "Secure Login Required",
  show_signup = TRUE,
  auto_refresh = TRUE
)

# Run app
shinyApp(ui, server)