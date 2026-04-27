# This file is used by Rack-based servers to start the application.

app_root = Dir.pwd
environment_path = File.expand_path("config/environment", app_root)
environment_path = File.expand_path("config/environment", __dir__) unless File.exist?(environment_path)

require environment_path

run Rails.application
Rails.application.load_server
