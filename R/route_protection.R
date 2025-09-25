#' Require Authentication Wrapper
#'
#' A higher-order function that wraps Shiny app content to require authentication.
#' Shows login form if user is not authenticated, otherwise shows the protected content.
#'
#' @param ui_function Function that returns the protected UI content
#' @param client Supabase client object
#' @param login_title Title for the login form (default: "Authentication Required")
#' @param show_signup Whether to show signup option (default: TRUE)
#'
#' @return A Shiny UI function that handles authentication
#' @export
#'
#' @importFrom shiny conditionalPanel
require_auth <- function(ui_function, client, login_title = "Authentication Required", show_signup = TRUE) {
  function(request) {
    shiny::tagList(
      # JavaScript to manage authentication state
      shiny::tags$script(HTML("
        window.shinySupabaseAuth = {
          authenticated: false,
          setAuth: function(status) {
            this.authenticated = status;
            Shiny.setInputValue('auth_status', status, {priority: 'event'});
          }
        };

        // Handler for authentication status updates
        Shiny.addCustomMessageHandler('supabase-auth-status', function(message) {
          window.shinySupabaseAuth.setAuth(message.authenticated);
        });
      ")),

      # Conditional panels based on authentication status
      shiny::conditionalPanel(
        condition = "!window.shinySupabaseAuth.authenticated",
        supabase_auth_ui("auth", title = login_title, show_signup = show_signup)
      ),

      shiny::conditionalPanel(
        condition = "window.shinySupabaseAuth.authenticated",
        ui_function(request)
      )
    )
  }
}

#' Authentication Guard for Server
#'
#' Server-side authentication guard that manages user state and protects server logic.
#'
#' @param client Supabase client object
#' @param protected_server_function Function containing the protected server logic
#'
#' @return A Shiny server function that handles authentication
#' @export
#'
#' @importFrom shiny observe req
auth_server_guard <- function(client, protected_server_function) {
  function(input, output, session) {

    # Initialize authentication module
    user_state <- supabase_auth_server("auth", client)

    # Monitor authentication state changes
    shiny::observe({
      current_state <- user_state()

      # Update client-side authentication status
      session$sendCustomMessage(
        type = "supabase-auth-status",
        message = list(authenticated = current_state$authenticated)
      )
    })

    # Only run protected server logic if authenticated
    shiny::observe({
      if (user_state()$authenticated) {
        protected_server_function(input, output, session, user_state)
      }
    })

    # Return user state for external use
    return(user_state)
  }
}

#' Protected Page Wrapper
#'
#' Simpler wrapper for individual pages that need authentication.
#'
#' @param content UI content to protect
#' @param fallback_content Content to show when not authenticated (optional)
#'
#' @return Protected UI content
#' @export
#'
#' @importFrom shiny div
protected_page <- function(content, fallback_content = NULL) {
  if (is.null(fallback_content)) {
    fallback_content <- shiny::div(
      style = "text-align: center; margin-top: 50px;",
      shiny::h3("Access Denied"),
      shiny::p("You need to be logged in to view this content.")
    )
  }

  shiny::conditionalPanel(
    condition = "window.shinySupabaseAuth.authenticated",
    content,
    shiny::conditionalPanel(
      condition = "!window.shinySupabaseAuth.authenticated",
      fallback_content
    )
  )
}

#' Session State Manager
#'
#' Manages user session state across page reloads and tab navigation.
#'
#' @param client Supabase client object
#' @param session Shiny session object
#'
#' @return Reactive containing persistent user state
#' @export
#'
#' @importFrom shiny reactive observe
session_manager <- function(client, session) {
  # Store session in browser storage
  session$sendCustomMessage(
    type = "supabase-session-init",
    message = list()
  )

  # Reactive to track session state
  user_session <- shiny::reactive({
    # This would be enhanced with actual session restoration logic
    list(
      authenticated = FALSE,
      user = NULL,
      access_token = NULL
    )
  })

  return(user_session)
}

#' User Role Checker
#'
#' Check if user has specific roles or permissions.
#'
#' @param user_state Current user state reactive
#' @param required_roles Vector of required roles
#' @param check_function Custom function to check permissions
#'
#' @return Logical indicating if user has required permissions
#' @export
#'
#' @importFrom shiny reactive
check_user_role <- function(user_state, required_roles = NULL, check_function = NULL) {
  shiny::reactive({
    current_user <- user_state()

    if (!current_user$authenticated) {
      return(FALSE)
    }

    if (!is.null(check_function)) {
      return(check_function(current_user))
    }

    if (!is.null(required_roles) && !is.null(current_user$user$app_metadata$roles)) {
      user_roles <- current_user$user$app_metadata$roles
      return(any(required_roles %in% user_roles))
    }

    # Default: authenticated users have access
    return(TRUE)
  })
}

#' Add JavaScript handlers for authentication
#'
#' Internal function to add necessary JavaScript for authentication state management.
#'
#' @return HTML script tag with JavaScript handlers
#' @keywords internal
auth_js_handlers <- function() {
  shiny::tags$script(HTML("
    // Handle authentication status updates
    Shiny.addCustomMessageHandler('supabase-auth-status', function(message) {
      window.shinySupabaseAuth.setAuth(message.authenticated);
    });

    // Handle session initialization
    Shiny.addCustomMessageHandler('supabase-session-init', function(message) {
      // Try to restore session from localStorage
      var savedAuth = localStorage.getItem('supabase-auth');
      if (savedAuth) {
        var authData = JSON.parse(savedAuth);
        // Validate token expiry here if needed
        window.shinySupabaseAuth.setAuth(authData.authenticated);
      }
    });

    // Save authentication state to localStorage
    window.addEventListener('beforeunload', function() {
      if (window.shinySupabaseAuth.authenticated) {
        localStorage.setItem('supabase-auth', JSON.stringify({
          authenticated: window.shinySupabaseAuth.authenticated,
          timestamp: Date.now()
        }));
      } else {
        localStorage.removeItem('supabase-auth');
      }
    });
  "))
}