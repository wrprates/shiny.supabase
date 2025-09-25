# Minimal Example - shiny.supabase

This is the simplest possible example of Supabase authentication.

## How to run

1. Configure your Supabase credentials:
   ```r
   # In .Renviron file (in user or project folder):
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

2. Run the app:
   ```r
   shiny::runApp("inst/examples/minimal")
   ```

## What this example demonstrates

- Basic Supabase client configuration
- Automatic login interface
- Simple route protection
- Basic logout

This example has only ~25 lines of code and is perfect for understanding the basic concept.