#' Supabase Authentication UI Module
#'
#' Creates a login/signup form UI for Supabase authentication.
#'
#' @param id Module namespace ID
#' @param title Title for the authentication form (default: "Login")
#' @param show_signup Whether to show signup option (default: TRUE)
#' @param custom_css Custom CSS classes for the container
#' @param custom_styles Raw CSS rules appended via \code{<style>} (optional)
#' @param class_map Named list of extra classes for UI slots (container, card,
#' title, panel, field, primary_button, secondary_button, link_wrap, messages)
#' @param theme Named list of CSS variable overrides for default auth theme
#' @param compact Use denser spacing for smaller layouts (default: FALSE)
#' @param enable_enter_submit Enable Enter key submit for login/signup (default: TRUE)
#'
#' @return A Shiny UI element
#' @export
#'
#' @importFrom shiny NS tagList div h3 textInput passwordInput actionButton uiOutput tags HTML
#' @importFrom shinyjs useShinyjs
supabase_auth_ui <- function(
  id,
  title = "Login",
  show_signup = TRUE,
  custom_css = NULL,
  custom_styles = NULL,
  class_map = NULL,
  theme = list(),
  compact = FALSE,
  enable_enter_submit = TRUE
) {
  ns <- shiny::NS(id)

  compose_class <- function(base, extra = NULL) {
    trimws(paste(base, extra))
  }
  class_map <- if (is.null(class_map)) list() else class_map
  theme <- if (is.null(theme)) list() else theme
  slot_class <- function(slot, base) {
    extra <- class_map[[slot]]
    if (is.null(extra) || identical(extra, "")) {
      return(base)
    }
    compose_class(base, extra)
  }

  theme_defaults <- list(
    max_width = "440px",
    page_padding = "20px",
    card_padding = "24px",
    radius = "14px",
    gap = "14px",
    bg = "#ffffff",
    border = "#e5e7eb",
    shadow = "0 12px 30px rgba(17, 24, 39, 0.08)",
    text = "#111827",
    muted = "#6b7280",
    primary = "#2563eb",
    primary_hover = "#1d4ed8",
    primary_text = "#ffffff",
    input_bg = "#ffffff",
    input_border = "#d1d5db",
    input_border_focus = "#2563eb",
    focus_ring = "rgba(37, 99, 235, 0.22)"
  )
  theme_values <- modifyList(theme_defaults, theme)
  container_style <- paste0(
    "--ssb-max-width:", theme_values$max_width, ";",
    "--ssb-page-padding:", theme_values$page_padding, ";",
    "--ssb-card-padding:", theme_values$card_padding, ";",
    "--ssb-radius:", theme_values$radius, ";",
    "--ssb-gap:", theme_values$gap, ";",
    "--ssb-bg:", theme_values$bg, ";",
    "--ssb-border:", theme_values$border, ";",
    "--ssb-shadow:", theme_values$shadow, ";",
    "--ssb-text:", theme_values$text, ";",
    "--ssb-muted:", theme_values$muted, ";",
    "--ssb-primary:", theme_values$primary, ";",
    "--ssb-primary-hover:", theme_values$primary_hover, ";",
    "--ssb-primary-text:", theme_values$primary_text, ";",
    "--ssb-input-bg:", theme_values$input_bg, ";",
    "--ssb-input-border:", theme_values$input_border, ";",
    "--ssb-input-border-focus:", theme_values$input_border_focus, ";",
    "--ssb-focus-ring:", theme_values$focus_ring, ";"
  )

  shiny::tagList(
    shinyjs::useShinyjs(),
    shiny::tags$style(shiny::HTML("
      .ssb-auth {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: var(--ssb-page-padding, 20px);
        color: var(--ssb-text, #111827);
      }
      .ssb-auth__card {
        width: 100%;
        max-width: var(--ssb-max-width, 440px);
        background: var(--ssb-bg, #ffffff);
        border: 1px solid var(--ssb-border, #e5e7eb);
        border-radius: var(--ssb-radius, 14px);
        box-shadow: var(--ssb-shadow, 0 12px 30px rgba(17,24,39,0.08));
        padding: var(--ssb-card-padding, 24px);
      }
      .ssb-auth__title {
        margin: 0 0 calc(var(--ssb-gap, 14px) + 4px) 0;
        text-align: center;
        font-size: 1.9rem;
        font-weight: 700;
        line-height: 1.2;
      }
      .ssb-auth__panel {
        display: grid;
        gap: var(--ssb-gap, 14px);
      }
      .ssb-auth__field {
        margin: 0;
      }
      .ssb-auth__field .shiny-input-container {
        width: 100%;
      }
      .ssb-auth__field .form-group {
        margin-bottom: 0;
      }
      .ssb-auth__field .control-label {
        display: block;
        margin-bottom: 6px;
        font-size: 0.88rem;
        font-weight: 600;
        letter-spacing: 0.01em;
        color: var(--ssb-text, #111827);
      }
      .ssb-auth__field .form-control {
        width: 100%;
        height: 44px;
        border-radius: 10px;
        border: 1px solid var(--ssb-input-border, #d1d5db);
        background: var(--ssb-input-bg, #ffffff);
        box-shadow: none;
        transition: border-color .15s ease, box-shadow .15s ease;
      }
      .ssb-auth__field .form-control:focus {
        border-color: var(--ssb-input-border-focus, #2563eb);
        box-shadow: 0 0 0 3px var(--ssb-focus-ring, rgba(37,99,235,.22));
      }
      .ssb-auth__primary {
        width: 100%;
        height: 44px;
        border: none;
        border-radius: 10px;
        background: var(--ssb-primary, #2563eb);
        color: var(--ssb-primary-text, #ffffff);
        font-weight: 600;
        transition: background-color .15s ease, transform .05s ease;
      }
      .ssb-auth__primary:hover,
      .ssb-auth__primary:focus {
        background: var(--ssb-primary-hover, #1d4ed8);
        color: var(--ssb-primary-text, #ffffff);
      }
      .ssb-auth__primary:active {
        transform: translateY(1px);
      }
      .ssb-auth__link-wrap {
        text-align: center;
      }
      .ssb-auth__link {
        border: none;
        background: none;
        text-decoration: underline;
        color: var(--ssb-primary, #2563eb);
        font-weight: 500;
      }
      .ssb-auth__messages {
        margin-top: 2px;
        min-height: 20px;
      }
      .ssb-auth__message {
        font-size: .9rem;
      }
      .ssb-auth__message--error {
        color: #b91c1c;
      }
      .ssb-auth__message--success {
        color: #047857;
      }
      .ssb-auth--compact {
        --ssb-card-padding: 16px;
        --ssb-gap: 10px;
      }
      @media (max-width: 520px) {
        .ssb-auth {
          padding: 12px;
        }
        .ssb-auth__card {
          border-radius: 12px;
          padding: 16px;
        }
        .ssb-auth__title {
          font-size: 1.55rem;
        }
      }
    ")),
    shiny::div(
      class = compose_class(
        compose_class(slot_class("container", "supabase-auth-container ssb-auth"), custom_css),
        if (isTRUE(compact)) "ssb-auth--compact" else NULL
      ),
      style = container_style,
      shiny::div(
        class = slot_class("card", "ssb-auth__card"),
        shiny::h3(title, class = slot_class("title", "ssb-auth__title")),
        shiny::div(
          id = ns("login_form"),
          class = slot_class("panel", "ssb-auth__panel"),
          shiny::div(
            class = slot_class("field", "ssb-auth__field"),
            shiny::textInput(ns("email"), "Email", placeholder = "you@email.com")
          ),
          shiny::div(
            class = slot_class("field", "ssb-auth__field"),
            shiny::passwordInput(ns("password"), "Password", placeholder = "Your password")
          ),
          shiny::actionButton(
            ns("login_btn"),
            "Sign In",
            class = slot_class("primary_button", "ssb-auth__primary btn-primary btn-block")
          ),
          if (show_signup) {
            shiny::div(
              class = slot_class("link_wrap", "ssb-auth__link-wrap"),
              shiny::actionButton(
                ns("show_signup"),
                "Create account",
                class = slot_class("secondary_button", "ssb-auth__link")
              )
            )
          }
        ),
        if (show_signup) {
          shiny::div(
            id = ns("signup_form"),
            class = slot_class("panel", "ssb-auth__panel"),
            style = "display:none;",
            shiny::div(
              class = slot_class("field", "ssb-auth__field"),
              shiny::textInput(ns("signup_email"), "Email", placeholder = "you@email.com")
            ),
            shiny::div(
              class = slot_class("field", "ssb-auth__field"),
              shiny::passwordInput(ns("signup_password"), "Password", placeholder = "Create a password")
            ),
            shiny::div(
              class = slot_class("field", "ssb-auth__field"),
              shiny::passwordInput(ns("signup_confirm"), "Confirm password", placeholder = "Re-enter your password")
            ),
            shiny::actionButton(
              ns("signup_btn"),
              "Create Account",
              class = slot_class("primary_button", "ssb-auth__primary btn-success btn-block")
            ),
            shiny::div(
              class = slot_class("link_wrap", "ssb-auth__link-wrap"),
              shiny::actionButton(
                ns("show_login"),
                "Already have account",
                class = slot_class("secondary_button", "ssb-auth__link")
              )
            )
          )
        },
        shiny::div(
          id = ns("messages"),
          class = slot_class("messages", "ssb-auth__messages"),
          shiny::uiOutput(ns("auth_messages"))
        )
      )
    ),
    if (isTRUE(enable_enter_submit)) {
      shiny::tags$script(shiny::HTML(sprintf(
        "
        (function() {
          var ns = '%s';
          var rootKey = '__ssb_enter_bind_' + ns;
          if (window[rootKey]) return;

          function triggerIfEnter(e, buttonId) {
            if (e.key === 'Enter') {
              e.preventDefault();
              var btn = document.getElementById(buttonId);
              if (btn) btn.click();
            }
          }

          function bind() {
            var loginBtn = ns + 'login_btn';
            var signupBtn = ns + 'signup_btn';
            var ids = [
              [ns + 'email', loginBtn],
              [ns + 'password', loginBtn],
              [ns + 'signup_email', signupBtn],
              [ns + 'signup_password', signupBtn],
              [ns + 'signup_confirm', signupBtn]
            ];

            ids.forEach(function(pair) {
              var input = document.getElementById(pair[0]);
              if (!input || input.dataset.ssbEnterBound === '1') return;
              input.addEventListener('keydown', function(e) { triggerIfEnter(e, pair[1]); });
              input.dataset.ssbEnterBound = '1';
            });
          }

          document.addEventListener('shiny:connected', bind);
          document.addEventListener('shiny:value', bind);
          setTimeout(bind, 0);
          window[rootKey] = true;
        })();
        ",
        ns("")
      )))
    },
    if (!is.null(custom_styles) && nzchar(paste(custom_styles, collapse = ""))) {
      shiny::tags$style(shiny::HTML(custom_styles))
    }
  )
}

#' Supabase Authentication Server Module
#'
#' Server logic for handling Supabase authentication.
#'
#' @param id Module namespace ID
#' @param client Supabase client object
#' @param redirect_on_success Whether to redirect after successful login (default: FALSE)
#'
#' @return A reactive containing user authentication state
#' @export
#'
#' @importFrom shiny moduleServer observeEvent reactive reactiveVal showNotification req renderUI div
#' @importFrom shinyjs show hide disable enable
supabase_auth_server <- function(id, client, redirect_on_success = FALSE) {
  shiny::moduleServer(id, function(input, output, session) {
    # Reactive values
    user_state <- shiny::reactiveVal(list(
      authenticated = FALSE,
      user = NULL,
      access_token = NULL
    ))
    auth_message <- shiny::reactiveVal(NULL)

    set_message <- function(text = NULL, type = "error") {
      if (is.null(text) || identical(text, "")) {
        auth_message(NULL)
        return(invisible(NULL))
      }
      auth_message(list(text = text, type = type))
      invisible(NULL)
    }

    output$auth_messages <- shiny::renderUI({
      msg <- auth_message()
      if (is.null(msg) || is.null(msg$text)) {
        return(NULL)
      }

      type_class <- if (identical(msg$type, "success")) {
        "ssb-auth__message--success"
      } else {
        "ssb-auth__message--error"
      }

      shiny::div(
        class = paste("ssb-auth__message", type_class),
        `aria-live` = "polite",
        msg$text
      )
    })

    # Toggle between login and signup forms
    shiny::observeEvent(input$show_signup, {
      shinyjs::hide("login_form")
      shinyjs::show("signup_form")
      set_message(NULL)
    })

    shiny::observeEvent(input$show_login, {
      shinyjs::show("login_form")
      shinyjs::hide("signup_form")
      set_message(NULL)
    })

    # Handle login
    shiny::observeEvent(input$login_btn, {
      shinyjs::disable("login_btn")
      on.exit(shinyjs::enable("login_btn"), add = TRUE)
      set_message(NULL)
      shiny::req(input$email, input$password)

      if (input$email == "" || input$password == "") {
        set_message("Email and password are required", type = "error")
        shiny::showNotification(
          "Email and password are required",
          type = "warning",
          duration = 5
        )
        return()
      }

      result <- supabase_signin(client, input$email, input$password)

      if (result$success) {
        set_message(NULL)
        # Store in server-side session state (secure)
        user_state(list(
          authenticated = TRUE,
          user = result$user,
          access_token = result$access_token,
          refresh_token = result$refresh_token,
          expires_at = result$expires_at
        ))

        # Also store in session$userData for persistence
        session$userData$supabase_auth <- list(
          authenticated = TRUE,
          user = result$user,
          access_token = result$access_token,
          refresh_token = result$refresh_token,
          expires_at = result$expires_at
        )

        shiny::showNotification(
          "Login successful!",
          type = "default",
          duration = 5
        )

        # Clear form
        shiny::updateTextInput(session, "email", value = "")
        shiny::updateTextInput(session, "password", value = "")
      } else {
        set_message(paste("Login error:", result$error), type = "error")
        shiny::showNotification(
          paste("Login error:", result$error),
          type = "warning",
          duration = 5
        )
      }
    })

    # Handle signup
    shiny::observeEvent(input$signup_btn, {
      shinyjs::disable("signup_btn")
      on.exit(shinyjs::enable("signup_btn"), add = TRUE)
      set_message(NULL)
      shiny::req(
        input$signup_email,
        input$signup_password,
        input$signup_confirm
      )

      if (input$signup_password != input$signup_confirm) {
        set_message("Passwords do not match", type = "error")
        shiny::showNotification(
          "Passwords do not match",
          type = "warning",
          duration = 5
        )
        return()
      }

      if (nchar(input$signup_password) < 6) {
        set_message("Password must have at least 6 characters", type = "error")
        shiny::showNotification(
          "Password must have at least 6 characters",
          type = "warning",
          duration = 5
        )
        return()
      }

      result <- supabase_signup(
        client,
        input$signup_email,
        input$signup_password
      )

      if (result$success) {
        set_message("Account created. Check your email for confirmation.", type = "success")
        shiny::showNotification(
          "Account created! Check your email for confirmation.",
          type = "default",
          duration = 5
        )

        # Switch back to login form
        shinyjs::show("login_form")
        shinyjs::hide("signup_form")

        # Clear signup form
        shiny::updateTextInput(session, "signup_email", value = "")
        shiny::updateTextInput(session, "signup_password", value = "")
        shiny::updateTextInput(session, "signup_confirm", value = "")
      } else {
        set_message(paste("Account creation error:", result$error), type = "error")
        shiny::showNotification(
          paste("Account creation error:", result$error),
          type = "warning",
          duration = 5
        )
      }
    })

    # Return authentication state
    return(user_state)
  })
}

#' Logout Button UI
#'
#' Creates a logout button.
#'
#' @param id Module namespace ID
#' @param label Button label (default: "Logout")
#' @param class CSS classes for the button
#'
#' @return A Shiny UI element
#' @export
#'
#' @importFrom shiny NS actionButton
supabase_logout_ui <- function(id, label = "Logout", class = "btn-danger") {
  ns <- shiny::NS(id)
  shiny::actionButton(ns("logout"), label, class = class)
}

#' Logout Server Module
#'
#' Server logic for handling logout.
#'
#' @param id Module namespace ID
#' @param client Supabase client object
#' @param user_state Reactive containing current user state
#' @param reload_on_logout Whether to reload the page after logout (default: FALSE)
#'
#' @return Updated user state reactive
#' @export
#'
#' @importFrom shiny moduleServer observeEvent showNotification
supabase_logout_server <- function(id, client, user_state, reload_on_logout = FALSE) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observeEvent(input$logout, {
      current_state <- user_state()

      if (current_state$authenticated && !is.null(current_state$access_token)) {
        result <- supabase_signout(client, current_state$access_token)

        if (result$success) {
          # Clear server-side session state
          user_state(list(
            authenticated = FALSE,
            user = NULL,
            access_token = NULL,
            refresh_token = NULL,
            expires_at = NULL
          ))

          # Clear session$userData
          session$userData$supabase_auth <- NULL

          # Show notification before reload (if enabled)
          if (!reload_on_logout) {
            shiny::showNotification(
              "Logout successful!",
              type = "message",
              duration = 3
            )
          }

          # Optional: reload page to ensure clean state
          if (reload_on_logout) {
            # Use a small delay to ensure state is cleared
            shiny::invalidateLater(100, session)
            shiny::observe({
              session$reload()
            })
          }
        } else {
          shiny::showNotification(
            paste("Logout error:", result$error %||% "Unknown error"),
            type = "error",
            duration = 5
          )
        }
      } else {
        shiny::showNotification(
          "User is not authenticated",
          type = "warning",
          duration = 5
        )
      }
    })

    user_state
  })
}
