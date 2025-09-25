# shiny.supabase

[![R-CMD-check](https://github.com/wrprates/shiny.supabase/workflows/R-CMD-check/badge.svg)](https://github.com/wrprates/shiny.supabase/actions)
[![CRAN status](https://www.r-pkg.org/badges/version/shiny.supabase)](https://CRAN.R-project.org/package=shiny.supabase)

Supabase authentication for Shiny applications. This package provides simple, secure authentication modules that integrate seamlessly with your existing Shiny apps.

## Installation

Install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("wrprates/shiny.supabase")
```

## Getting Started

### Prerequisites

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from Settings → API
3. Configure environment variables in `.Renviron`:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### Quick Example

```r
library(shiny)
library(shiny.supabase)

# Configure Supabase client
client <- supabase_client(
  url = Sys.getenv("SUPABASE_URL"),
  key = Sys.getenv("SUPABASE_ANON_KEY")
)

# Protected UI function
protected_ui <- function(request) {
  fluidPage(
    titlePanel("Protected App"),
    h3("Welcome! You are authenticated."),
    supabase_logout_ui("logout", "Sign Out")
  )
}

# Protected server function
protected_server <- function(input, output, session, user_state) {
  supabase_logout_server("logout", client, user_state)
}

# Create app with authentication
ui <- require_auth(protected_ui, client, "Please Sign In")
server <- auth_server_guard(client, protected_server)

shinyApp(ui, server)
```

## Examples

The package includes three complete example applications:

```r
# Minimal example (~25 lines)
shiny::runApp(system.file("examples/minimal", package = "shiny.supabase"))

# Basic example with user info
shiny::runApp(system.file("examples/basic", package = "shiny.supabase"))

# Advanced dashboard
shiny::runApp(system.file("examples/advanced", package = "shiny.supabase"))
```

## Features

- **Email/password authentication** with automatic signup
- **Route protection** for entire apps or specific pages
- **Session management** with reactive user state
- **Modular design** - use individual auth components
- **Customizable UI** - integrate with any Shiny UI framework

## API Reference

### Core Functions

| Function | Description |
|----------|-------------|
| `supabase_client()` | Initialize Supabase client |
| `require_auth()` | Protect entire application |
| `auth_server_guard()` | Protect server logic |

### UI Modules

| Function | Description |
|----------|-------------|
| `supabase_auth_ui()` | Login/signup interface |
| `supabase_logout_ui()` | Logout button |

### Server Modules

| Function | Description |
|----------|-------------|
| `supabase_auth_server()` | Authentication logic |
| `supabase_logout_server()` | Logout logic |

## Configuration

### Supabase Setup

1. **Create project** at [supabase.com](https://supabase.com)
2. **Configure authentication** in Dashboard:
   - Go to Authentication → Settings
   - Enable desired auth providers
   - For development: disable email confirmations
3. **Get credentials** from Settings → API

### Environment Variables

Create `.Renviron` in your project root:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

Restart R after creating/modifying `.Renviron`.

## Troubleshooting

**Installation fails**: Update R and install dependencies manually
```r
install.packages(c("shiny", "httr2", "jsonlite", "shinyjs", "DT"))
```

**Login not working**: Check Supabase auth settings and console for errors

**Environment variables not found**: Restart R and verify `.Renviron` location

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Code of Conduct

This project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing you agree to abide by its terms.

## License

MIT © [Wlademir Prates](https://github.com/wrprates)