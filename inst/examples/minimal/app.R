# Minimal Example - shiny.supabase
# The simplest possible authentication setup

library(shiny)
library(shiny.supabase)

# Configure client (use your real credentials)
client <- supabase_client(
  url = Sys.getenv("SUPABASE_URL"),
  key = Sys.getenv("SUPABASE_ANON_KEY")
)

# Protected UI
protected_ui <- function(request) {
  fluidPage(
    titlePanel("Minimal App"),
    h3("You are authenticated!"),
    p("This is the simplest possible example."),
    supabase_logout_ui("logout", "Sign Out")
  )
}

# Protected server
protected_server <- function(input, output, session, user_state) {
  supabase_logout_server("logout", client, user_state)
}

# Protected app
ui <- require_auth(protected_ui, client, "Login")
server <- auth_server_guard(client, protected_server)

shinyApp(ui, server)