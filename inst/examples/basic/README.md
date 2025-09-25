# Basic Example - shiny.supabase

Demonstrates basic usage with more complete interface and user information.

## How to run

1. Configure your Supabase credentials:
   ```r
   # In .Renviron file:
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

2. Run the app:
   ```r
   shiny::runApp("inst/examples/basic")
   ```

## What this example demonstrates

- Login interface with custom title
- Display of authenticated user information
- Real-time session status
- Responsive layout with sidebar
- Styled logout button

Perfect for understanding how to access user data and customize the interface.