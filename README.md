# shiny.supabase

[![R-CMD-check](https://github.com/wrprates/shiny.supabase/workflows/R-CMD-check/badge.svg)](https://github.com/wrprates/shiny.supabase/actions)

An R package that makes it easy to integrate Supabase authentication with Shiny applications.

## 🚀 Quick Start

### 1. **Install the Package**

```r
# Install development version
remotes::install_github("wrprates/shiny.supabase")

# Load the package
library(shiny.supabase)
```

### 2. **Configure Supabase**

1. **Create project:** [supabase.com](https://supabase.com) → New Project
2. **Get credentials:** Settings → API
3. **Configure `.Renviron`:**
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

### 3. **Basic Usage**

```r
library(shiny)
library(shiny.supabase)

# Configure client
client <- supabase_client(
  url = Sys.getenv("SUPABASE_URL"),
  key = Sys.getenv("SUPABASE_ANON_KEY")
)

# Protected UI
protected_ui <- function(request) {
  fluidPage(
    h1("Protected Content"),
    supabase_logout_ui("logout", "Sign Out")
  )
}

# Protected server
protected_server <- function(input, output, session, user_state) {
  supabase_logout_server("logout", client, user_state)
}

# Create protected app
ui <- require_auth(protected_ui, client, "Please Sign In")
server <- auth_server_guard(client, protected_server)

shinyApp(ui, server)
```

## 📖 Examples

This package includes three example applications to get you started:

### 📋 [Minimal Example](inst/examples/minimal/)
The simplest possible implementation (~25 lines)
```r
shiny::runApp(system.file("examples/minimal", package = "shiny.supabase"))
```

### 🏠 [Basic Example](inst/examples/basic/)
Standard usage with user information display
```r
shiny::runApp(system.file("examples/basic", package = "shiny.supabase"))
```

### 🚀 [Advanced Example](inst/examples/advanced/)
Complete dashboard with shinydashboard
```r
shiny::runApp(system.file("examples/advanced", package = "shiny.supabase"))
```

## 🔧 Supabase Configuration

### **1. Create Project**

1. Go to [supabase.com](https://supabase.com)
2. Sign in/up
3. "New Project" → choose name and region
4. Note down database password

### **2. Get Credentials**

In dashboard: **Settings → API**
- **Project URL**: `https://abcdefg.supabase.co`
- **anon public key**: `eyJhbGciOiJIUzI1NiIs...`

### **3. Configure Authentication**

**Authentication → Settings:**
- **Enable email confirmations**: OFF (for local development)
- **Enable phone confirmations**: OFF
- **Email auth**: ON
- **Enable signup**: ON

### **4. Setup .Renviron**

Create/edit `.Renviron` in your project root:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Important:** Restart R after editing!

## 📦 Package Functions

### **Core Functions**

**Client:**
- `supabase_client()` - Initialize client
- `supabase_signin()` - Sign in
- `supabase_signup()` - Sign up
- `supabase_signout()` - Sign out
- `get_user_info()` - Get user information

**Shiny Modules:**
- `supabase_auth_ui()` - Login/signup interface
- `supabase_auth_server()` - Authentication logic
- `supabase_logout_ui()` - Logout button
- `supabase_logout_server()` - Logout logic

**Protection:**
- `require_auth()` - Protect entire application
- `auth_server_guard()` - Protect server logic
- `protected_page()` - Protect specific pages

## ❌ Troubleshooting

### **Error: "Credentials not found"**
- Check `.Renviron` in project root
- Restart R: `.rs.restartR()`
- Test: `Sys.getenv("SUPABASE_URL")`

### **Error: "Invalid API key"**
- Use **anon key**, not service_role
- Copy complete key from Supabase
- Verify project is active

### **Login not working**
- Check Supabase authentication settings
- Verify email confirmation is disabled for development
- Check browser console for errors

## 🎯 Features

- 🔐 **Login/Signup** with email/password
- 🛡️ **Automatic route protection**
- 👤 **User management** and sessions
- 🎨 **Customizable UI** with modules
- 🔄 **Reactive authentication** state
- 📱 **Responsive interface**
- 🔒 **Security** with JWT tokens

## 🚀 Roadmap

- [ ] OAuth providers (Google, GitHub)
- [ ] Automatic token refresh
- [ ] Additional UI templates
- [ ] Role/permission system
- [ ] Automated tests
- [ ] CRAN submission

## 🤝 Contributing

1. Fork the repository
2. Create branch: `git checkout -b feature/new-feature`
3. Commit: `git commit -am 'Add new feature'`
4. Push: `git push origin feature/new-feature`
5. Open Pull Request

## 📞 Support

- 🐛 [Issues](https://github.com/wrprates/shiny.supabase/issues)
- 💬 [Discussions](https://github.com/wrprates/shiny.supabase/discussions)
- 📧 Email: wrprates@yahoo.com

## 📄 License

MIT License - Copyright (c) 2024 Wlademir Prates

---

**Your first R package for Supabase authentication is ready!** 🎉

*This project makes Supabase + Shiny integration accessible to the entire R community.*