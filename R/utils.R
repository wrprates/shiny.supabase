#' Utility Functions
#'
#' Internal utility functions for the shiny.supabase package.
#'
#' @name utils
#' @keywords internal
NULL

#' NULL Coalescing Operator
#'
#' Returns the right-hand side if the left-hand side is NULL.
#'
#' @param x First value
#' @param y Second value (returned if x is NULL)
#'
#' @return x if not NULL, otherwise y
#' @keywords internal
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' Safe List Access
#'
#' Safely access nested list elements without errors.
#'
#' @param lst List to access
#' @param ... Keys to access (nested)
#' @param default Default value if not found
#'
#' @return Value at the specified path or default
#' @keywords internal
#' @noRd
safe_list_get <- function(lst, ..., default = NULL) {
  keys <- list(...)
  current <- lst

  for (key in keys) {
    if (is.null(current) || !is.list(current) || !key %in% names(current)) {
      return(default)
    }
    current <- current[[key]]
  }

  current %||% default
}

#' Validate Email Format
#'
#' Simple email validation for client-side checks.
#'
#' @param email Email address to validate
#'
#' @return Logical indicating if email format is valid
#' @keywords internal
#' @noRd
is_valid_email <- function(email) {
  if (is.null(email) || !is.character(email) || length(email) != 1) {
    return(FALSE)
  }

  email_pattern <- "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
  grepl(email_pattern, email)
}

#' Sanitize User Input
#'
#' Basic sanitization of user input to prevent injection attacks.
#'
#' @param input User input string
#' @param max_length Maximum allowed length
#'
#' @return Sanitized input
#' @keywords internal
#' @noRd
sanitize_input <- function(input, max_length = 255) {
  if (is.null(input) || !is.character(input)) {
    return("")
  }

  # Trim whitespace
  input <- trimws(input)

  # Limit length
  if (nchar(input) > max_length) {
    input <- substr(input, 1, max_length)
  }

  # Remove null bytes and control characters
  input <- gsub("\\x00|[\\x01-\\x08\\x0B-\\x0C\\x0E-\\x1F]", "", input)

  input
}

#' Check if Session is Valid
#'
#' Validates if a Shiny session object is valid and active.
#'
#' @param session Shiny session object
#'
#' @return Logical indicating if session is valid
#' @keywords internal
#' @noRd
is_valid_session <- function(session) {
  !is.null(session) &&
    inherits(session, "ShinySession") &&
    !session$closed
}

#' Generate Secure Random String
#'
#' Generates a secure random string for state tokens.
#'
#' @param length Length of the random string
#'
#' @return Random string
#' @keywords internal
#' @noRd
generate_random_string <- function(length = 32) {
  chars <- c(letters, LETTERS, 0:9)
  paste(sample(chars, length, replace = TRUE), collapse = "")
}

#' Log Security Event
#'
#' Logs security-related events for auditing purposes.
#' In production, this should integrate with proper logging systems.
#'
#' @param event_type Type of security event
#' @param message Event message
#' @param session Shiny session object (optional)
#'
#' @return NULL (invisible)
#' @keywords internal
#' @noRd
log_security_event <- function(event_type, message, session = NULL) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  session_id <- if (!is.null(session)) session$token else "unknown"

  log_message <- sprintf(
    "[%s] SECURITY [%s] Session: %s - %s",
    timestamp,
    event_type,
    session_id,
    message
  )

  # In CRAN package, we use message() instead of cat()
  # This can be overridden by package users
  if (getOption("shiny.supabase.log_security", FALSE)) {
    message(log_message)
  }

  invisible(NULL)
}

#' Rate Limiter
#'
#' Simple in-memory rate limiter for authentication attempts.
#'
#' @param key Identifier for rate limiting (e.g., IP, session)
#' @param max_attempts Maximum attempts allowed
#' @param window_seconds Time window in seconds
#'
#' @return Logical indicating if rate limit is exceeded
#' @keywords internal
#' @noRd
check_rate_limit <- function(key, max_attempts = 5, window_seconds = 300) {
  # Get or create rate limit cache
  cache_env <- getOption("shiny.supabase.rate_limit_cache")

  if (is.null(cache_env)) {
    cache_env <- new.env(parent = emptyenv())
    options(shiny.supabase.rate_limit_cache = cache_env)
  }

  current_time <- Sys.time()

  # Get attempts for this key
  if (!exists(key, envir = cache_env)) {
    cache_env[[key]] <- list(attempts = 1, first_attempt = current_time)
    return(FALSE)
  }

  attempts_data <- cache_env[[key]]
  time_diff <- as.numeric(difftime(current_time, attempts_data$first_attempt, units = "secs"))

  # Reset if outside window
  if (time_diff > window_seconds) {
    cache_env[[key]] <- list(attempts = 1, first_attempt = current_time)
    return(FALSE)
  }

  # Increment attempts
  attempts_data$attempts <- attempts_data$attempts + 1
  cache_env[[key]] <- attempts_data

  # Check if limit exceeded
  if (attempts_data$attempts > max_attempts) {
    log_security_event(
      "RATE_LIMIT_EXCEEDED",
      sprintf("Key: %s exceeded %d attempts in %d seconds", key, max_attempts, window_seconds)
    )
    return(TRUE)
  }

  return(FALSE)
}

#' Clear Rate Limit
#'
#' Clears rate limit for a specific key (e.g., after successful auth).
#'
#' @param key Identifier to clear
#'
#' @return NULL (invisible)
#' @keywords internal
#' @noRd
clear_rate_limit <- function(key) {
  cache_env <- getOption("shiny.supabase.rate_limit_cache")

  if (!is.null(cache_env) && exists(key, envir = cache_env)) {
    rm(list = key, envir = cache_env)
  }

  invisible(NULL)
}

#' Validate Supabase Client Object
#'
#' Checks if an object is a valid supabase_client.
#'
#' @param client Object to validate
#'
#' @return Logical indicating if client is valid
#' @keywords internal
#' @noRd
is_valid_supabase_client <- function(client) {
  inherits(client, "supabase_client") &&
    !is.null(client$url) &&
    !is.null(client$key) &&
    !is.null(client$auth_url)
}

#' Package Startup Message
#'
#' Display message when package is loaded.
#'
#' @param libname Library name
#' @param pkgname Package name
#'
#' @return NULL (invisible)
#' @keywords internal
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "shiny.supabase: Secure Supabase authentication for Shiny\n",
    "All authentication is handled server-side for maximum security.\n",
    "Report issues at: https://github.com/wrprates/shiny.supabase/issues"
  )

  invisible(NULL)
}
