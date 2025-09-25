# shiny.supabase 0.1.0

## Major Changes

* 🎉 **Initial release** of shiny.supabase package
* 🏗️ **Package restructuring**: Moved from nested `shinySupabase/` to proper R package structure
* 📝 **Renamed package**: `shinySupabase` → `shiny.supabase` to follow community conventions

## New Features

* ✨ **Core authentication functions**:
  - `supabase_client()`: Initialize Supabase client
  - `require_auth()`: Protect UI with authentication
  - `auth_server_guard()`: Protect server logic
  - `supabase_login_ui()` / `supabase_login_server()`: Login modules
  - `supabase_logout_ui()` / `supabase_logout_server()`: Logout modules

* 📱 **Complete authentication flow**:
  - Email/password login
  - Magic link support
  - OAuth providers (when configured in Supabase)
  - Session management
  - Automatic token validation

* 🔒 **Route protection utilities**:
  - UI and server protection wrappers
  - User state management
  - Automatic redirects on authentication changes

## Examples and Documentation

* 📚 **Three example apps**:
  - **Minimal**: Simplest possible implementation (~25 lines)
  - **Basic**: Standard usage with user info display
  - **Advanced**: Complete dashboard with shinydashboard

* 📖 **Comprehensive documentation**:
  - README for each example
  - Setup instructions with .Renviron.example
  - Function documentation

## Installation

```r
# Install development version
remotes::install_github("wrprates/shiny.supabase")

# Load the package
library(shiny.supabase)
```

## Quick Start

```r
library(shiny)
library(shiny.supabase)

# Configure client
client <- supabase_client(
  url = Sys.getenv("SUPABASE_URL"),
  key = Sys.getenv("SUPABASE_ANON_KEY")
)

# Protected UI
protected_ui <- function(request) {
  fluidPage(
    h1("Protected Content"),
    supabase_logout_ui("logout", "Sign Out")
  )
}

# Protected server
protected_server <- function(input, output, session, user_state) {
  supabase_logout_server("logout", client, user_state)
}

# Create protected app
ui <- require_auth(protected_ui, client, "Please Sign In")
server <- auth_server_guard(client, protected_server)

shinyApp(ui, server)
```