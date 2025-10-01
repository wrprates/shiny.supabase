# Security Policy

## Overview

`shiny.supabase` implements enterprise-grade security for Shiny applications using Supabase authentication. All authentication logic is handled **server-side only** to prevent client-side manipulation.

## Security Architecture

### Server-Side Authentication (v0.1.0+)

All authentication state is stored and validated exclusively on the server:

- ✅ **No client-side state exposure** - Authentication tokens never reach the browser
- ✅ **Server-side token validation** - All tokens validated with Supabase on every critical operation
- ✅ **Automatic token refresh** - Expired tokens automatically refreshed server-side
- ✅ **Session hijacking prevention** - Tokens stored in server memory only
- ✅ **Rate limiting** - Built-in protection against brute force attacks
- ✅ **Server-side rendering** - Protected content only rendered after authentication

### What This Prevents

1. **Client-Side Bypass Attacks**
   - Users cannot manipulate browser localStorage or sessionStorage to fake authentication
   - DevTools manipulation (e.g., `window.auth = true`) has no effect
   - DOM inspection reveals no authentication tokens

2. **Session Hijacking**
   - Tokens are never exposed in client-side JavaScript
   - No XSS attack can steal authentication tokens
   - Session state stored in server memory only

3. **Token Theft**
   - Access tokens never stored in cookies or localStorage
   - Refresh tokens handled server-side only
   - No token exposure in network traffic to client

4. **Replay Attacks**
   - Token expiration enforced server-side
   - Automatic validation with Supabase backend
   - Stale tokens automatically rejected

## Security Best Practices

### For Package Users

1. **Never expose credentials in code**
   ```r
   # ✅ Good - use environment variables
   client <- supabase_client(
     url = Sys.getenv("SUPABASE_URL"),
     key = Sys.getenv("SUPABASE_ANON_KEY")
   )

   # ❌ Bad - hardcoded credentials
   client <- supabase_client(
     url = "https://myproject.supabase.co",
     key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   )
   ```

2. **Enable automatic token refresh**
   ```r
   server <- auth_server_guard(
     client,
     protected_server,
     ui_function = protected_ui,
     auto_refresh = TRUE  # Recommended
   )
   ```

3. **Use HTTPS in production**
   - Always deploy Shiny apps with HTTPS enabled
   - Never send authentication requests over HTTP

4. **Implement proper access control**
   ```r
   protected_server <- function(input, output, session, user_state) {
     # Validate user has permission
     user <- validate_user_permission(user_state, function(user) {
       "admin" %in% user$app_metadata$roles
     })

     if (is.null(user)) {
       return(NULL)  # Stop execution if not authorized
     }

     # ... protected logic here
   }
   ```

5. **Enable security logging (optional)**
   ```r
   # Enable security event logging for auditing
   options(shiny.supabase.log_security = TRUE)
   ```

### For Production Deployments

1. **Environment Variables**
   - Store `SUPABASE_URL` and `SUPABASE_ANON_KEY` in environment variables
   - Never commit credentials to version control
   - Use secret management services (AWS Secrets Manager, HashiCorp Vault, etc.)

2. **Network Security**
   - Deploy behind a reverse proxy (nginx, Apache)
   - Enable HTTPS with valid SSL certificates
   - Configure proper CORS headers on Supabase

3. **Session Configuration**
   - Set appropriate session timeout values
   - Configure Supabase token expiration policies
   - Implement logout on browser close if needed

4. **Monitoring**
   - Enable security logging
   - Monitor failed authentication attempts
   - Set up alerts for suspicious activity

## Reporting Security Vulnerabilities

If you discover a security vulnerability in `shiny.supabase`, please report it responsibly:

1. **Do NOT** create a public GitHub issue
2. Email the maintainer directly: wrprates@yahoo.com
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

We will acknowledge receipt within 48 hours and provide a timeline for a fix.

## Security Changelog

### Version 0.1.0 (2024)

**Major Security Overhaul - Server-Side Authentication**

- ✅ Removed all client-side authentication state management
- ✅ Implemented server-side token validation with Supabase
- ✅ Added automatic token refresh mechanism
- ✅ Introduced session security manager
- ✅ Implemented server-side conditional rendering
- ✅ Added rate limiting for authentication attempts
- ✅ Removed vulnerable `window.shinySupabaseAuth` JavaScript object
- ✅ Eliminated `localStorage` authentication persistence
- ✅ Removed `conditionalPanel` based on client-side JavaScript

**Breaking Changes:**
- Client-side `window.shinySupabaseAuth` object removed
- `conditionalPanel` with JavaScript conditions no longer used
- Authentication state not accessible in browser

**Migration Guide:**
All existing apps using `shiny.supabase` should update to v0.1.0 immediately for security fixes. The API remains largely compatible - see examples for updated usage.

## Security Audit Status

- **Last Internal Audit:** 2024 (during v0.1.0 development)
- **CRAN Compliance:** Pending submission
- **Known Vulnerabilities:** None (as of v0.1.0)

## License

This security policy is part of the `shiny.supabase` package licensed under MIT.
