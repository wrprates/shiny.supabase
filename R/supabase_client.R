#' Create Supabase Client
#'
#' Initialize a Supabase client with your project URL and API key.
#'
#' @param url Your Supabase project URL (e.g., "https://your-project.supabase.co")
#' @param key Your Supabase anon/public API key
#' @param schema Database schema to use (default: "public")
#'
#' @return A list containing the Supabase client configuration
#' @export
#'
#' @examples
#' \dontrun{
#' client <- supabase_client(
#'   url = "https://your-project.supabase.co",
#'   key = "your-anon-key"
#' )
#' }
supabase_client <- function(url, key, schema = "public") {
  if (missing(url) || missing(key)) {
    stop("Both 'url' and 'key' are required")
  }

  # Ensure URL doesn't end with slash
  url <- gsub("/$", "", url)

  structure(
    list(
      url = url,
      key = key,
      schema = schema,
      auth_url = paste0(url, "/auth/v1"),
      rest_url = paste0(url, "/rest/v1")
    ),
    class = "supabase_client"
  )
}

#' Sign in with email and password
#'
#' Authenticate a user with email and password using Supabase Auth.
#'
#' @param client A Supabase client created with \code{supabase_client()}
#' @param email User's email address
#' @param password User's password
#'
#' @return A list containing user information and access token, or NULL if failed
#' @export
#'
#' @importFrom httr2 request req_headers req_body_json req_perform resp_body_json resp_status
#' @importFrom jsonlite toJSON
supabase_signin <- function(client, email, password) {
  if (!inherits(client, "supabase_client")) {
    stop("'client' must be a supabase_client object")
  }

  tryCatch(
    {
      response <- httr2::request(paste0(
        client$auth_url,
        "/token?grant_type=password"
      )) |>
        httr2::req_headers(
          "apikey" = client$key,
          "Content-Type" = "application/json"
        ) |>
        httr2::req_body_json(list(
          grant_type = "password",
          email = email,
          password = password
        )) |>
        httr2::req_perform()

      if (httr2::resp_status(response) == 200) {
        result <- httr2::resp_body_json(response)
        return(list(
          success = TRUE,
          user = result$user,
          access_token = result$access_token,
          refresh_token = result$refresh_token,
          expires_at = result$expires_at
        ))
      } else {
        return(list(success = FALSE, error = "Invalid credentials"))
      }
    },
    error = function(e) {
      return(list(success = FALSE, error = e$message))
    }
  )
}

#' Sign up with email and password
#'
#' Create a new user account with email and password.
#'
#' @param client A Supabase client created with \code{supabase_client()}
#' @param email User's email address
#' @param password User's password
#' @param metadata Optional user metadata (list)
#'
#' @return A list containing user information, or error if failed
#' @export
#'
#' @importFrom httr2 request req_headers req_body_json req_perform resp_body_json resp_status
supabase_signup <- function(client, email, password, metadata = NULL) {
  if (!inherits(client, "supabase_client")) {
    stop("'client' must be a supabase_client object")
  }

  body <- list(
    email = email,
    password = password
  )

  if (!is.null(metadata)) {
    body$data <- metadata
  }

  tryCatch(
    {
      response <- httr2::request(paste0(client$auth_url, "/signup")) |>
        httr2::req_headers(
          "apikey" = client$key,
          "Content-Type" = "application/json"
        ) |>
        httr2::req_body_json(body) |>
        httr2::req_perform()

      result <- httr2::resp_body_json(response)

      if (httr2::resp_status(response) == 200) {
        return(list(
          success = TRUE,
          user = result$user,
          message = "Check your email for confirmation link"
        ))
      } else {
        return(list(
          success = FALSE,
          error = result$error_description %||% result$msg %||% "Signup failed"
        ))
      }
    },
    error = function(e) {
      return(list(success = FALSE, error = e$message))
    }
  )
}

#' Sign out user
#'
#' Sign out the current user and invalidate their session.
#'
#' @param client A Supabase client created with \code{supabase_client()}
#' @param access_token User's current access token
#'
#' @return A list with success status
#' @export
#'
#' @importFrom httr2 request req_headers req_perform resp_status
supabase_signout <- function(client, access_token) {
  if (!inherits(client, "supabase_client")) {
    stop("'client' must be a supabase_client object")
  }

  tryCatch(
    {
      response <- httr2::request(paste0(client$auth_url, "/logout")) |>
        httr2::req_headers(
          "apikey" = client$key,
          "Authorization" = paste("Bearer", access_token),
          "Content-Type" = "application/json"
        ) |>
        httr2::req_body_json(list()) |>
        httr2::req_perform()

      status <- httr2::resp_status(response)
      return(list(success = status %in% c(200, 204)))
    },
    error = function(e) {
      return(list(success = FALSE, error = e$message))
    }
  )
}

#' Get user information
#'
#' Retrieve current user information using access token.
#'
#' @param client A Supabase client created with \code{supabase_client()}
#' @param access_token User's access token
#'
#' @return User information or NULL if failed
#' @export
#'
#' @importFrom httr2 request req_headers req_perform resp_body_json resp_status
get_user_info <- function(client, access_token) {
  if (!inherits(client, "supabase_client")) {
    stop("'client' must be a supabase_client object")
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
        return(httr2::resp_body_json(response))
      } else {
        return(NULL)
      }
    },
    error = function(e) {
      return(NULL)
    }
  )
}

# Helper function for NULL coalescing
`%||%` <- function(x, y) if (is.null(x)) y else x
