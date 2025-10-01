#' Require Authentication Wrapper
#'
#' A higher-order function that wraps Shiny app content to require authentication.
#' Shows login form if user is not authenticated, otherwise shows the protected content.
#' All authentication logic is handled server-side for security.
#'
#' @param ui_function Function that returns the protected UI content
#' @param client Supabase client object
#' @param login_title Title for the login form (default: "Authentication Required")
#' @param show_signup Whether to show signup option (default: TRUE)
#'
#' @return A Shiny UI function that handles authentication
#' @export
#'
#' @importFrom shiny uiOutput
require_auth <- function(
  ui_function,
  client,
  login_title = "Authentication Required",
  show_signup = TRUE
) {
  function(request) {
    # Main content area - rendered server-side based on auth status
    shiny::uiOutput("__supabase_main_content__")
  }
}

#' Authentication Guard for Server
#'
#' Server-side authentication guard that manages user state and protects server logic.
#' All authentication state is stored server-side only. No client-side state exposure.
#'
#' @param client Supabase client object
#' @param protected_server_function Function containing the protected server logic
#' @param ui_function UI function for protected content (required with require_auth)
#' @param login_title Title for the login form (default: "Authentication Required")
#' @param show_signup Whether to show signup option (default: TRUE)
#' @param auto_refresh Enable automatic token refresh (default: TRUE)
#'
#' @return A Shiny server function that handles authentication
#' @export
#'
#' @importFrom shiny observe req renderUI invalidateLater
auth_server_guard <- function(
  client,
  protected_server_function,
  ui_function = NULL,
  login_title = "Authentication Required",
  show_signup = TRUE,
  auto_refresh = TRUE
) {
  function(input, output, session, request = NULL) {
    # Initialize secure session state (server-side only)
    user_state <- init_secure_session(session)

    # Initialize authentication module
    auth_state <- supabase_auth_server("auth", client)

    # Sync auth module state with secure session state (login direction)
    shiny::observe({
      auth_data <- auth_state()

      if (auth_data$authenticated) {
        update_session_state(
          user_state,
          authenticated = TRUE,
          user = auth_data$user,
          access_token = auth_data$access_token,
          refresh_token = auth_data$refresh_token,
          expires_at = auth_data$expires_at
        )
      }
    })

    # Sync logout: when user_state becomes unauthenticated, clear auth_state too
    shiny::observe({
      current_state <- user_state()
      current_auth <- auth_state()

      # If user_state is not authenticated but auth_state is, sync the logout
      if (!current_state$authenticated && current_auth$authenticated) {
        auth_state(list(
          authenticated = FALSE,
          user = NULL,
          access_token = NULL,
          refresh_token = NULL,
          expires_at = NULL
        ))
      }
    })

    # Automatic token validation and refresh
    if (auto_refresh) {
      shiny::observe({
        shiny::invalidateLater(60000) # Check every minute

        current_state <- user_state()
        if (current_state$authenticated) {
          # Validate and refresh if necessary
          validate_and_refresh_session(client, user_state, force_validate = FALSE)
        }
      })
    }

    # Render main content based on authentication state (SERVER-SIDE)
    output$`__supabase_main_content__` <- shiny::renderUI({
      current_state <- user_state()

      if (current_state$authenticated) {
        # User is authenticated - render protected content
        if (!is.null(ui_function)) {
          if (is.function(ui_function)) {
            ui_function(request)
          } else {
            ui_function
          }
        } else {
          shiny::div(
            style = "padding: 20px;",
            shiny::h3("Protected Content"),
            shiny::p("You are authenticated!")
          )
        }
      } else {
        # User not authenticated - show login form
        supabase_auth_ui("auth", title = login_title, show_signup = show_signup)
      }
    })

    # Initialize protected server logic
    protected_server_function(input, output, session, user_state)

    # Return user state for external use
    return(user_state)
  }
}

#' Protected Page Wrapper
#'
#' Server-side wrapper for individual pages that need authentication.
#' Use this within renderUI to conditionally show content based on auth state.
#'
#' @param user_state Reactive containing authentication state
#' @param content UI content to protect (can be function or UI object)
#' @param fallback_content Content to show when not authenticated (optional)
#'
#' @return Protected UI content based on authentication state
#' @export
#'
#' @importFrom shiny div
protected_page <- function(user_state, content, fallback_content = NULL) {
  current_state <- user_state()

  if (current_state$authenticated) {
    # Render protected content
    if (is.function(content)) {
      return(content(current_state$user))
    } else {
      return(content)
    }
  } else {
    # Render fallback content
    if (is.null(fallback_content)) {
      return(shiny::div(
        style = "text-align: center; margin-top: 50px;",
        shiny::h3("Access Denied"),
        shiny::p("You need to be logged in to view this content.")
      ))
    } else {
      if (is.function(fallback_content)) {
        return(fallback_content())
      } else {
        return(fallback_content)
      }
    }
  }
}

#' Session State Manager
#'
#' Creates and manages secure server-side session state.
#' No client-side storage or exposure of tokens.
#'
#' @param client Supabase client object
#' @param session Shiny session object
#'
#' @return Reactive containing persistent user state
#' @export
#'
#' @importFrom shiny reactive
session_manager <- function(client, session) {
  # Initialize secure server-side session
  user_state <- init_secure_session(session)

  return(user_state)
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
check_user_role <- function(
  user_state,
  required_roles = NULL,
  check_function = NULL
) {
  shiny::reactive({
    current_user <- user_state()

    if (!current_user$authenticated) {
      return(FALSE)
    }

    if (!is.null(check_function)) {
      return(check_function(current_user))
    }

    if (
      !is.null(required_roles) && !is.null(current_user$user$app_metadata$roles)
    ) {
      user_roles <- current_user$user$app_metadata$roles
      return(any(required_roles %in% user_roles))
    }

    # Default: authenticated users have access
    return(TRUE)
  })
}

#' Validate User Permissions Server-Side
#'
#' Server-side helper to validate user has required permissions.
#' Returns NULL if user doesn't have permission, stopping reactive execution.
#'
#' @param user_state Reactive containing authentication state
#' @param check_function Custom function to check permissions
#'
#' @return User object if authorized, NULL otherwise
#' @export
#'
#' @importFrom shiny req
validate_user_permission <- function(user_state, check_function = NULL) {
  current_state <- user_state()

  if (!current_state$authenticated) {
    return(NULL)
  }

  if (!is.null(check_function)) {
    has_permission <- check_function(current_state$user)
    if (!has_permission) {
      return(NULL)
    }
  }

  return(current_state$user)
}
