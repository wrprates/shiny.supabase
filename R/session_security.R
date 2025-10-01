#' Session Security Manager
#'
#' Internal functions for secure server-side session management.
#' All authentication state is stored server-side only.
#'
#' @name session_security
#' @keywords internal
NULL

#' Initialize Secure Session State
#'
#' Creates a secure session state stored entirely server-side.
#' Never exposes tokens or authentication state to the client.
#'
#' @param session Shiny session object
#'
#' @return A reactiveVal containing session state
#' @keywords internal
#'
#' @importFrom shiny reactiveVal
init_secure_session <- function(session) {
  # Initialize session state in server memory only
  state <- shiny::reactiveVal(list(
    authenticated = FALSE,
    user = NULL,
    access_token = NULL,
    refresh_token = NULL,
    expires_at = NULL,
    last_validated = NULL
  ))

  # Store state reference in session$userData (server-side only)
  session$userData$auth_state <- state

  return(state)
}

#' Validate Token with Supabase
#'
#' Validates an access token by making a request to Supabase.
#' This ensures the token is still valid and not revoked.
#'
#' @param client Supabase client object
#' @param access_token Token to validate
#'
#' @return List with validation result and user info
#' @keywords internal
#'
#' @importFrom httr2 request req_headers req_perform resp_status resp_body_json
validate_token <- function(client, access_token) {
  if (is.null(access_token) || access_token == "") {
    return(list(valid = FALSE, user = NULL))
  }

  tryCatch(
    {
      response <- httr2::request(paste0(client$auth_url, "/user")) |>
        httr2::req_headers(
          "apikey" = client$key,
          "Authorization" = paste("Bearer", access_token)
        ) |>
        httr2::req_perform()

      if (httr2::resp_status(response) == 200) {
        user <- httr2::resp_body_json(response)
        return(list(valid = TRUE, user = user))
      } else {
        return(list(valid = FALSE, user = NULL))
      }
    },
    error = function(e) {
      return(list(valid = FALSE, user = NULL, error = e$message))
    }
  )
}

#' Check if Token is Expired
#'
#' Checks if a token has expired based on expires_at timestamp.
#'
#' @param expires_at Token expiration timestamp (Unix time)
#' @param buffer_seconds Safety buffer in seconds (default: 60)
#'
#' @return Logical indicating if token is expired
#' @keywords internal
is_token_expired <- function(expires_at, buffer_seconds = 60) {
  if (is.null(expires_at)) {
    return(TRUE)
  }

  current_time <- as.numeric(Sys.time())
  expires_numeric <- as.numeric(expires_at)

  # Add buffer to refresh before actual expiry
  return((expires_numeric - buffer_seconds) <= current_time)
}

#' Refresh Access Token
#'
#' Uses refresh token to obtain a new access token from Supabase.
#'
#' @param client Supabase client object
#' @param refresh_token Refresh token
#'
#' @return List with new tokens or error
#' @keywords internal
#'
#' @importFrom httr2 request req_headers req_body_json req_perform resp_status resp_body_json
refresh_access_token <- function(client, refresh_token) {
  if (is.null(refresh_token) || refresh_token == "") {
    return(list(success = FALSE, error = "No refresh token provided"))
  }

  tryCatch(
    {
      response <- httr2::request(paste0(
        client$auth_url,
        "/token?grant_type=refresh_token"
      )) |>
        httr2::req_headers(
          "apikey" = client$key,
          "Content-Type" = "application/json"
        ) |>
        httr2::req_body_json(list(
          refresh_token = refresh_token
        )) |>
        httr2::req_perform()

      if (httr2::resp_status(response) == 200) {
        result <- httr2::resp_body_json(response)
        return(list(
          success = TRUE,
          access_token = result$access_token,
          refresh_token = result$refresh_token,
          expires_at = result$expires_at,
          user = result$user
        ))
      } else {
        return(list(success = FALSE, error = "Token refresh failed"))
      }
    },
    error = function(e) {
      return(list(success = FALSE, error = e$message))
    }
  )
}

#' Update Session State Securely
#'
#' Updates session state with new authentication data.
#' All data remains server-side only.
#'
#' @param state_reactive ReactiveVal containing session state
#' @param authenticated Authentication status
#' @param user User object
#' @param access_token Access token
#' @param refresh_token Refresh token
#' @param expires_at Token expiration timestamp
#'
#' @return Updated state
#' @keywords internal
update_session_state <- function(
  state_reactive,
  authenticated = FALSE,
  user = NULL,
  access_token = NULL,
  refresh_token = NULL,
  expires_at = NULL
) {
  state_reactive(list(
    authenticated = authenticated,
    user = user,
    access_token = access_token,
    refresh_token = refresh_token,
    expires_at = expires_at,
    last_validated = if (authenticated) Sys.time() else NULL
  ))

  return(state_reactive())
}

#' Clear Session State
#'
#' Clears all authentication data from session.
#'
#' @param state_reactive ReactiveVal containing session state
#'
#' @return Cleared state
#' @keywords internal
clear_session_state <- function(state_reactive) {
  update_session_state(
    state_reactive,
    authenticated = FALSE,
    user = NULL,
    access_token = NULL,
    refresh_token = NULL,
    expires_at = NULL
  )
}

#' Validate and Refresh Session
#'
#' Comprehensive session validation that checks token validity
#' and refreshes if necessary.
#'
#' @param client Supabase client object
#' @param state_reactive ReactiveVal containing session state
#' @param force_validate Force validation even if recently validated
#'
#' @return Updated session state
#' @keywords internal
validate_and_refresh_session <- function(
  client,
  state_reactive,
  force_validate = FALSE
) {
  current_state <- state_reactive()

  if (!current_state$authenticated) {
    return(current_state)
  }

  # Check if we need to validate (avoid excessive API calls)
  if (!force_validate && !is.null(current_state$last_validated)) {
    time_since_validation <- as.numeric(difftime(
      Sys.time(),
      current_state$last_validated,
      units = "secs"
    ))

    # Only validate every 5 minutes unless forced
    if (time_since_validation < 300) {
      return(current_state)
    }
  }

  # Check if token is expired
  if (is_token_expired(current_state$expires_at)) {
    # Try to refresh token
    refresh_result <- refresh_access_token(client, current_state$refresh_token)

    if (refresh_result$success) {
      # Update session with new tokens
      update_session_state(
        state_reactive,
        authenticated = TRUE,
        user = refresh_result$user,
        access_token = refresh_result$access_token,
        refresh_token = refresh_result$refresh_token,
        expires_at = refresh_result$expires_at
      )
      return(state_reactive())
    } else {
      # Refresh failed, clear session
      clear_session_state(state_reactive)
      return(state_reactive())
    }
  }

  # Validate current token
  validation_result <- validate_token(client, current_state$access_token)

  if (validation_result$valid) {
    # Update last validated time
    current_state$last_validated <- Sys.time()
    state_reactive(current_state)
    return(current_state)
  } else {
    # Token invalid, clear session
    clear_session_state(state_reactive)
    return(state_reactive())
  }
}

#' Require Authentication Guard
#'
#' Server-side guard that ensures user is authenticated.
#' Returns NULL if not authenticated, preventing code execution.
#'
#' @param state_reactive ReactiveVal containing session state
#' @param message Custom message for unauthenticated users
#'
#' @return User object if authenticated, NULL otherwise
#' @keywords internal
#'
#' @importFrom shiny req
require_authenticated <- function(state_reactive, message = "Authentication required") {
  current_state <- state_reactive()

  if (!current_state$authenticated) {
    return(NULL)
  }

  shiny::req(current_state$authenticated, cancelOutput = TRUE)

  return(current_state$user)
}
