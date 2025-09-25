# Advanced Demo App - shiny.supabase Package
# This is a demo app showing advanced features of shiny.supabase package

library(shiny)
library(shinydashboard)
library(DT)

# Use installed package
library(shiny.supabase)

# =====================================================
# CONFIGURATION - LOADED FROM .Renviron
# =====================================================

# Load environment variables from .Renviron
SUPABASE_URL <- Sys.getenv("SUPABASE_URL")
SUPABASE_KEY <- gsub('"', '', Sys.getenv("SUPABASE_ANON_KEY"))  # Remove quotes

# Validate if credentials were loaded
if (SUPABASE_URL == "" || SUPABASE_KEY == "") {
  stop("❌ Supabase credentials not found!\n",
       "Configure .Renviron file with:\n",
       "SUPABASE_URL=https://your-project.supabase.co\n",
       "SUPABASE_ANON_KEY=your-anon-key-here\n\n",
       "Then restart R with: .rs.restartR()")
}

# Create Supabase client
supabase <- supabase_client(
  url = SUPABASE_URL,
  key = SUPABASE_KEY
)

# =====================================================
# PROTECTED UI
# =====================================================

protected_ui <- function(request) {
  dashboardPage(
    dashboardHeader(title = "App with Supabase Auth"),

    dashboardSidebar(
      sidebarMenu(
        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("Data", tabName = "data", icon = icon("table")),
        menuItem("Profile", tabName = "profile", icon = icon("user"))
      ),

      # Logout button
      div(style = "position: absolute; bottom: 20px; left: 20px; right: 20px;",
          supabase_logout_ui("logout", "Sign Out", class = "btn-danger btn-block")
      )
    ),

    dashboardBody(
      tags$head(
        tags$style(HTML("
          .content-wrapper, .right-side {
            background-color: #f4f4f4;
          }
          .auth-info {
            background: #fff;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #00a65a;
          }
        "))
      ),

      tabItems(
        # Dashboard Tab
        tabItem(tabName = "dashboard",
          fluidRow(
            box(
              title = "Bem-vindo!", status = "success", solidHeader = TRUE, width = 12,
              h4("Você está autenticado com sucesso!"),
              p("Este é um exemplo de app Shiny protegido por autenticação Supabase."),

              div(class = "auth-info",
                  h5("Informações do Usuário:"),
                  verbatimTextOutput("user_info")
              )
            )
          ),

          fluidRow(
            valueBox(
              value = textOutput("user_email"),
              subtitle = "Email do Usuário",
              icon = icon("envelope"),
              color = "blue",
              width = 4
            ),
            valueBox(
              value = "Ativo",
              subtitle = "Status da Sessão",
              icon = icon("check-circle"),
              color = "green",
              width = 4
            ),
            valueBox(
              value = textOutput("login_time"),
              subtitle = "Hora do Login",
              icon = icon("clock"),
              color = "purple",
              width = 4
            )
          )
        ),

        # Data Tab
        tabItem(tabName = "data",
          fluidRow(
            box(
              title = "Dados Protegidos", status = "primary", solidHeader = TRUE, width = 12,
              p("Este conteúdo só é visível para usuários autenticados."),
              DTOutput("demo_table")
            )
          )
        ),

        # Profile Tab
        tabItem(tabName = "profile",
          fluidRow(
            box(
              title = "Perfil do Usuário", status = "info", solidHeader = TRUE, width = 8,
              h4("Dados do Perfil"),
              verbatimTextOutput("profile_details"),

              br(),
              h5("Actions:"),
              actionButton("refresh_profile", "Refresh Profile",
                          class = "btn-info", icon = icon("refresh"))
            ),

            box(
              title = "Estatísticas", status = "warning", solidHeader = TRUE, width = 4,
              h5("Sessão Atual"),
              p(strong("Token válido:"), textOutput("token_status", inline = TRUE)),
              p(strong("Último acesso:"), textOutput("last_access", inline = TRUE)),

              br(),
              actionButton("test_api", "Testar API",
                          class = "btn-warning", icon = icon("cog"))
            )
          )
        )
      )
    )
  )
}

# =====================================================
# SERVIDOR PROTEGIDO
# =====================================================

protected_server <- function(input, output, session, user_state) {

  # Módulo de logout
  user_state <- supabase_logout_server("logout", supabase, user_state)

  # User data
  output$user_info <- renderText({
    current_user <- user_state()
    if (current_user$authenticated && !is.null(current_user$user)) {
      user_data <- current_user$user
      paste(
        "ID:", user_data$id, "\n",
        "Email:", user_data$email, "\n",
        "Criado em:", user_data$created_at, "\n",
        "Last login:", user_data$last_sign_in_at %||% "N/A"
      )
    } else {
      "User not authenticated"
    }
  })

  output$user_email <- renderText({
    current_user <- user_state()
    if (current_user$authenticated && !is.null(current_user$user)) {
      current_user$user$email
    } else {
      "N/A"
    }
  })

  output$login_time <- renderText({
    format(Sys.time(), "%H:%M")
  })

  # Tabela de exemplo
  output$demo_table <- renderDT({
    datatable(
      data.frame(
        ID = 1:10,
        Name = paste("User", 1:10),
        Email = paste0("user", 1:10, "@example.com"),
        Status = sample(c("Active", "Inactive"), 10, replace = TRUE),
        Date = Sys.Date() - sample(1:100, 10)
      ),
      options = list(pageLength = 5, scrollX = TRUE)
    )
  })

  # Profile details
  output$profile_details <- renderText({
    current_user <- user_state()
    if (current_user$authenticated && !is.null(current_user$user)) {
      user_data <- current_user$user

      # Show more profile details
      details <- list(
        "User ID" = user_data$id,
        "Email" = user_data$email,
        "Email confirmed" = user_data$email_confirmed_at %||% "Not confirmed",
        "Telefone" = user_data$phone %||% "Não informado",
        "Criado em" = user_data$created_at,
        "Atualizado em" = user_data$updated_at,
        "Last login" = user_data$last_sign_in_at %||% "N/A"
      )

      paste(names(details), details, sep = ": ", collapse = "\n")
    } else {
      "Profile data not available"
    }
  })

  output$token_status <- renderText({
    current_user <- user_state()
    if (current_user$authenticated && !is.null(current_user$access_token)) {
      "✓ Válido"
    } else {
      "✗ Inválido"
    }
  })

  output$last_access <- renderText({
    format(Sys.time(), "%d/%m/%Y %H:%M:%S")
  })

  # Refresh profile
  observeEvent(input$refresh_profile, {
    current_user <- user_state()
    if (current_user$authenticated && !is.null(current_user$access_token)) {
      updated_user <- get_user_info(supabase, current_user$access_token)

      if (!is.null(updated_user)) {
        showNotification("Profile updated successfully!", type = "default")
      } else {
        showNotification("Error updating profile", type = "warning")
      }
    }
  })

  # Test API
  observeEvent(input$test_api, {
    current_user <- user_state()
    if (current_user$authenticated && !is.null(current_user$access_token)) {
      # Teste simples de validação de token
      user_info <- get_user_info(supabase, current_user$access_token)

      if (!is.null(user_info)) {
        showNotification("API working correctly!", type = "default", duration = 3)
      } else {
        showNotification("API error - token may have expired", type = "warning", duration = 5)
      }
    }
  })

  # Disconnection monitor
  observe({
    current_user <- user_state()
    if (!current_user$authenticated) {
      session$reload()
    }
  })
}

# =====================================================
# APP PRINCIPAL
# =====================================================

ui <- require_auth(
  ui_function = protected_ui,
  client = supabase,
  login_title = "Sign In to System",
  show_signup = TRUE
)

server <- auth_server_guard(
  client = supabase,
  protected_server_function = protected_server
)

# Executar o app
shinyApp(ui = ui, server = server)