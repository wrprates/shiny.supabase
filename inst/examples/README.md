# Examples - shiny.supabase

This directory contains practical examples of `shiny.supabase` package usage.

## Available Examples

### 📋 [Minimal](minimal/)
The simplest possible example (~25 lines)
- Basic configuration
- Essential login/logout
- Perfect to get started

### 🏠 [Basic](basic/)
More complete interface with user data
- Sidebar layout
- User information
- Session status

### 🚀 [Advanced](advanced/)
Complete and professional dashboard
- shinydashboard
- Multiple pages
- Interactive tables
- Complete profile

## How to use the examples

1. **Configure Supabase**: Create a project at [supabase.com](https://supabase.com)

2. **Configure credentials**:
   ```r
   # .Renviron file (in user or project directory)
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

3. **Run an example**:
   ```r
   # From installed package
   shiny::runApp(system.file("examples/basic", package = "shiny.supabase"))

   # Or directly
   shiny::runApp("inst/examples/basic")
   ```

## Supabase Authentication

The examples work with any authentication method enabled in Supabase:
- Email/Password
- Magic Links
- OAuth (Google, GitHub, etc)
- Phone/SMS

Configure desired providers in Supabase Dashboard > Authentication > Providers.

## Next Steps

After testing the examples, see:
- [Vignettes](../../vignettes/) for detailed tutorials
- [Templates](../templates/) to start new projects
- [Function documentation](../../man/) for complete reference