# shiny.supabase 0.1.0

## 🔒 MAJOR SECURITY OVERHAUL - Server-Side Authentication

This release represents a **complete security rewrite** of the authentication system. All authentication is now handled server-side, eliminating critical client-side vulnerabilities.

### Critical Security Fixes

* ⚠️ **FIXED: Client-side authentication bypass vulnerability** - Users could previously manipulate browser localStorage or JavaScript to fake authentication
* ⚠️ **FIXED: Token exposure in client** - Tokens are now stored server-side only, never exposed to browser
* ⚠️ **FIXED: Unvalidated session persistence** - All sessions now validated with Supabase backend
* ⚠️ **FIXED: Protected content sent to unauthenticated clients** - Content now rendered server-side only after validation

### New Security Features

* ✅ **Server-Side Token Validation** - All tokens validated with Supabase on every critical operation
* ✅ **Automatic Token Refresh** - Expired tokens automatically refreshed server-side without user intervention
* ✅ **Session Security Manager** - Secure server-side session state management
* ✅ **Server-Side Rendering** - Protected content only rendered after server-side authentication check
* ✅ **Bidirectional State Sync** - Logout properly syncs between auth_state and user_state
* ✅ **Optional Page Reload on Logout** - Clean UI state after logout with `reload_on_logout` parameter
* ✅ **Rate Limiting** - Built-in protection against brute force authentication attempts
* ✅ **Security Event Logging** - Optional security event logging for audit trails

### New Functions

* `init_secure_session()` - Initialize secure server-side session state
* `validate_token()` - Validate access token with Supabase backend
* `refresh_access_token()` - Refresh expired tokens server-side
* `validate_and_refresh_session()` - Comprehensive session validation and refresh
* `update_session_state()` - Secure session state updates
* `clear_session_state()` - Clear authentication data from session
* `validate_user_permission()` - Server-side permission checking
* `protected_page()` - Server-side page protection (updated signature)
* Rate limiting utilities and security helpers

### Breaking Changes

⚠️ **These changes are necessary for security. All apps must be updated.**

* **Removed** `window.shinySupabaseAuth` JavaScript object (security vulnerability)
* **Removed** client-side `localStorage` authentication (security vulnerability)
* **Changed** `conditionalPanel` to server-side `renderUI`
* **Updated** `auth_server_guard()` to require `ui_function` parameter
* **Updated** `protected_page()` to require `user_state` as first parameter

### Migration Guide

**Before (insecure):**
```r
ui <- require_auth(protected_ui, client, "Login")
server <- auth_server_guard(client, protected_server)
```

**After (secure):**
```r
ui <- require_auth(protected_ui, client, "Login")
server <- auth_server_guard(
  client,
  protected_server,
  ui_function = protected_ui,  # Add this
  auto_refresh = TRUE          # Enable auto-refresh
)
```

## Documentation

* 📖 **NEW: SECURITY.md** - Comprehensive security architecture documentation
* 📖 **Updated examples** - All examples updated to use secure implementation
* 📖 **Security best practices** - Production deployment guidelines
* 📚 **Complete function documentation** - All functions documented with roxygen2

## Installation

```r
# Install development version
remotes::install_github("wrprates/shiny.supabase")

# Load the package
library(shiny.supabase)
```

## Quick Start

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