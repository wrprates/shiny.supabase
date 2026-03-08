# Exemplo Básico em Português - shiny.supabase
# Demonstra autenticação Supabase com interface traduzida

library(shiny)
library(shiny.supabase)

# Configuração do cliente Supabase
client <- supabase_client(
  url = Sys.getenv("SUPABASE_URL", "https://your-project.supabase.co"),
  key = Sys.getenv("SUPABASE_ANON_KEY", "your-anon-key")
)

# UI protegida
protected_ui <- function(request) {
  fluidPage(
    titlePanel("App Básico com Autenticação Supabase"),

    sidebarLayout(
      sidebarPanel(
        h4("Menu"),
        p("Você está logado com segurança."),
        p("Toda autenticação é tratada no servidor."),
        br(),
        supabase_logout_ui("logout", "Sair")
      ),

      mainPanel(
        h3("Área Protegida"),
        p("Este conteúdo só aparece para usuários autenticados."),

        fluidRow(
          column(6,
            wellPanel(
              h4("Informações do Usuário"),
              verbatimTextOutput("user_data")
            )
          ),
          column(6,
            wellPanel(
              h4("Status da Sessão"),
              textOutput("session_status"),
              hr(),
              p("Auto-refresh de token ativado", style = "color: green; font-size: 12px;")
            )
          )
        )
      )
    )
  )
}

# Server protegido
protected_server <- function(input, output, session, user_state) {
  user_state <- supabase_logout_server("logout", client, user_state, reload_on_logout = TRUE)

  output$user_data <- renderText({
    current_user <- user_state()

    if (current_user$authenticated && !is.null(current_user$user)) {
      paste(
        "E-mail:", current_user$user$email, "\n",
        "ID:", current_user$user$id, "\n",
        "Criado em:", current_user$user$created_at, "\n",
        "Última validação:", format(current_user$last_validated %||% Sys.time(), "%Y-%m-%d %H:%M:%S")
      )
    } else {
      "Usuário não autenticado"
    }
  })

  output$session_status <- renderText({
    current_user <- user_state()

    if (current_user$authenticated) {
      token_expires <- if (!is.null(current_user$expires_at)) {
        format(as.POSIXct(current_user$expires_at, origin = "1970-01-01"), "%Y-%m-%d %H:%M:%S")
      } else {
        "Desconhecido"
      }

      paste0(
        "✅ Sessão ativa\n",
        "Token expira em: ", token_expires
      )
    } else {
      "❌ Sessão inativa"
    }
  })
}

# Wrappers de autenticação
ui <- require_auth(protected_ui, client, "Entrar no sistema")
server <- auth_server_guard(
  client,
  protected_server,
  ui_function = protected_ui,
  login_title = "Entrar no sistema",
  show_signup = TRUE,
  auto_refresh = TRUE,
  auth_ui_options = list(
    text = list(
      email_label = "E-mail",
      password_label = "Senha",
      confirm_password_label = "Confirmar senha",
      login_email_placeholder = "voce@empresa.com",
      login_password_placeholder = "Digite sua senha",
      signup_email_placeholder = "voce@empresa.com",
      signup_password_placeholder = "Crie uma senha",
      signup_confirm_placeholder = "Repita a senha",
      login_button = "Entrar",
      create_account_link = "Criar conta",
      create_account_button = "Cadastrar",
      already_account_link = "Já tenho conta"
    )
  )
)

shinyApp(ui, server)
