# Exemplo Básico em Português - shiny.supabase

Demonstra o uso básico do pacote com interface de autenticação traduzida para português.

## Como rodar

1. Configure suas credenciais Supabase:
   ```r
   # No arquivo .Renviron:
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

2. Rode o app:
   ```r
   shiny::runApp("inst/examples/basic-pt")
   ```

## O que este exemplo demonstra

- Login/cadastro com textos em português
- Customização de rótulos, placeholders e botões via `auth_ui_options$text`
- Exibição de dados do usuário autenticado
- Status de sessão em tempo real
- Logout com reload
