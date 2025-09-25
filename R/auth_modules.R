#' Supabase Authentication UI Module
#'
#' Creates a login/signup form UI for Supabase authentication.
#'
#' @param id Module namespace ID
#' @param title Title for the authentication form (default: "Login")
#' @param show_signup Whether to show signup option (default: TRUE)
#' @param custom_css Custom CSS classes for styling
#'
#' @return A Shiny UI element
#' @export
#'
#' @importFrom shiny NS tagList fluidPage div h3 textInput passwordInput actionButton
#' @importFrom shinyjs useShinyjs
supabase_auth_ui <- function(id, title = "Login", show_signup = TRUE, custom_css = NULL) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shinyjs::useShinyjs(),
    shiny::div(
      class = paste("supabase-auth-container", custom_css),
      style = "max-width: 400px; margin: 50px auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px;",

      shiny::h3(title, style = "text-align: center; margin-bottom: 20px;"),

      # Login Form
      shiny::div(
        id = ns("login_form"),
        shiny::textInput(
          ns("email"),
          "Email:",
          placeholder = "seu@email.com"
        ),
        shiny::passwordInput(
          ns("password"),
          "Password:",
          placeholder = "Sua senha"
        ),
        shiny::actionButton(
          ns("login_btn"),
          "Entrar",
          class = "btn-primary btn-block",
          style = "width: 100%; margin-bottom: 10px;"
        ),
        if (show_signup) {
          shiny::div(
            style = "text-align: center;",
            shiny::actionButton(
              ns("show_signup"),
              "Criar conta",
              class = "btn-link",
              style = "padding: 0; border: none; background: none; color: #007bff; text-decoration: underline;"
            )
          )
        }
      ),

      # Signup Form (initially hidden)
      if (show_signup) {
        shiny::div(
          id = ns("signup_form"),
          style = "display: none;",
          shiny::textInput(
            ns("signup_email"),
            "Email:",
            placeholder = "seu@email.com"
          ),
          shiny::passwordInput(
            ns("signup_password"),
            "Password:",
            placeholder = "Sua senha"
          ),
          shiny::passwordInput(
            ns("signup_confirm"),
            "Confirmar Password:",
            placeholder = "Confirme sua senha"
          ),
          shiny::actionButton(
            ns("signup_btn"),
            "Criar Conta",
            class = "btn-success btn-block",
            style = "width: 100%; margin-bottom: 10px;"
          ),
          shiny::div(
            style = "text-align: center;",
            shiny::actionButton(
              ns("show_login"),
              "Já tenho conta",
              class = "btn-link",
              style = "padding: 0; border: none; background: none; color: #007bff; text-decoration: underline;"
            )
          )
        )
      },

      # Messages
      shiny::div(
        id = ns("messages"),
        style = "margin-top: 15px;"
      )
    )
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
#' @importFrom shiny moduleServer observeEvent reactive reactiveVal showNotification req
#' @importFrom shinyjs show hide
supabase_auth_server <- function(id, client, redirect_on_success = FALSE) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Reactive values
    user_state <- shiny::reactiveVal(list(
      authenticated = FALSE,
      user = NULL,
      access_token = NULL
    ))

    # Toggle between login and signup forms
    shiny::observeEvent(input$show_signup, {
      shinyjs::hide("login_form")
      shinyjs::show("signup_form")
    })

    shiny::observeEvent(input$show_login, {
      shinyjs::show("login_form")
      shinyjs::hide("signup_form")
    })

    # Handle login
    shiny::observeEvent(input$login_btn, {
      shiny::req(input$email, input$password)

      if (input$email == "" || input$password == "") {
        shiny::showNotification(
          "Email e senha são obrigatórios",
          type = "warning",
          duration = 3
        )
        return()
      }

      result <- supabase_signin(client, input$email, input$password)

      if (result$success) {
        user_state(list(
          authenticated = TRUE,
          user = result$user,
          access_token = result$access_token,
          refresh_token = result$refresh_token
        ))

        shiny::showNotification(
          "Login realizado com sucesso!",
          type = "default",
          duration = 3
        )

        # Clear form
        shiny::updateTextInput(session, "email", value = "")
        shiny::updateTextInput(session, "password", value = "")

      } else {
        shiny::showNotification(
          paste("Erro no login:", result$error),
          type = "warning",
          duration = 5
        )
      }
    })

    # Handle signup
    shiny::observeEvent(input$signup_btn, {
      shiny::req(input$signup_email, input$signup_password, input$signup_confirm)

      if (input$signup_password != input$signup_confirm) {
        shiny::showNotification(
          "As senhas não coincidem",
          type = "warning",
          duration = 3
        )
        return()
      }

      if (nchar(input$signup_password) < 6) {
        shiny::showNotification(
          "A senha deve ter pelo menos 6 caracteres",
          type = "warning",
          duration = 3
        )
        return()
      }

      result <- supabase_signup(client, input$signup_email, input$signup_password)

      if (result$success) {
        shiny::showNotification(
          "Conta criada! Verifique seu email para confirmação.",
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
        shiny::showNotification(
          paste("Erro ao criar conta:", result$error),
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
#'
#' @return Updated user state reactive
#' @export
#'
#' @importFrom shiny moduleServer observeEvent showNotification
supabase_logout_server <- function(id, client, user_state) {
  shiny::moduleServer(id, function(input, output, session) {

    shiny::observeEvent(input$logout, {
      current_state <- user_state()

      if (current_state$authenticated && !is.null(current_state$access_token)) {
        result <- supabase_signout(client, current_state$access_token)

        if (result$success) {
          user_state(list(
            authenticated = FALSE,
            user = NULL,
            access_token = NULL
          ))

          shiny::showNotification(
            "Logout realizado com sucesso!",
            type = "default",
            duration = 3
          )
        } else {
          shiny::showNotification(
            "Erro no logout",
            type = "warning",
            duration = 3
          )
        }
      }
    })

    return(user_state)
  })
}