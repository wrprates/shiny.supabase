#!/usr/bin/env Rscript

# Script to run the basic example app with proper environment variables

cat("\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║  shiny.supabase - Exemplo Básico com Autenticação Segura  ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

# Set environment variables
Sys.setenv(SUPABASE_URL = "https://qakrjsyixbupvnppbeeg.supabase.co")
Sys.setenv(SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFha3Jqc3lpeGJ1cHZucHBiZWVnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1MTA1MzcsImV4cCI6MjA3NDA4NjUzN30.ePRhyIQH5fWlmMQrn1dyegp4xsxwPkrY1lWnuRV78wM")

cat("✅ Variáveis de ambiente configuradas\n")
cat("   SUPABASE_URL:", Sys.getenv("SUPABASE_URL"), "\n")
cat("   SUPABASE_ANON_KEY: ******** (", nchar(Sys.getenv("SUPABASE_ANON_KEY")), " chars)\n\n")

# Load package from source
cat("📦 Carregando pacote...\n")
devtools::load_all(".", quiet = TRUE)

cat("\n🚀 Iniciando aplicação Shiny...\n")
cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")

cat("📝 CREDENCIAIS DE TESTE:\n")
cat("   Email: teste@example.com\n")
cat("   Senha: senha123456\n\n")

cat("🔒 SEGURANÇA:\n")
cat("   • Toda autenticação é server-side\n")
cat("   • Tokens nunca expostos ao browser\n")
cat("   • Validação automática a cada 5 minutos\n")
cat("   • Refresh automático de tokens\n\n")

cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

# Run the app
shiny::runApp("inst/examples/basic")
