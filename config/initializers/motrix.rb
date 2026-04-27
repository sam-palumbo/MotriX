Rails.application.configure do
  config.x.supabase.url = ENV["SUPABASE_URL"]
  config.x.supabase.anon_key = ENV["SUPABASE_ANON_KEY"]
  config.x.supabase.service_role_key = ENV["SUPABASE_SERVICE_ROLE_KEY"]
  config.x.supabase.bucket = ENV.fetch("SUPABASE_BUCKET", "motrix-anexos")
  config.x.app_host = ENV.fetch("APP_HOST", "http://localhost:3000")
end
