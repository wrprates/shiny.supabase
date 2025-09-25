# Advanced Example - shiny.supabase

Complete dashboard with multiple pages, data tables, and user profile.

## How to run

1. Configure your Supabase credentials:
   ```bash
   # Create .Renviron file in project or user folder:
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

2. Run the app:
   ```r
   shiny::runApp("inst/examples/advanced")
   ```

## What this example demonstrates

### Complete Interface
- Dashboard with shinydashboard
- Multiple tabs (Dashboard, Data, Profile)
- Responsive and professional design

### Advanced Features
- **Dashboard**: Value boxes with user metrics
- **Data**: Interactive table with DT
- **Profile**: Complete user details
- **API Testing**: Button to test connection

### Session Management
- Valid token monitoring
- Automatic data refresh
- Logout with confirmation
- Automatic redirection

This example shows how to build a complete and professional application using shiny.supabase.