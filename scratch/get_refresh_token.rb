require_relative "../config/environment"
require "google_drive"
require "googleauth"
require "googleauth/stores/file_token_store"

client_id = ENV["GOOGLE_DRIVE_CLIENT_ID"]
client_secret = ENV["GOOGLE_DRIVE_CLIENT_SECRET"]

scope = [ "https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/drive.file" ]
client_id_obj = Google::Auth::ClientId.new(client_id, client_secret)
token_store = Google::Auth::Stores::FileTokenStore.new(file: "tmp/tokens.yaml")
authorizer = Google::Auth::UserAuthorizer.new(client_id_obj, scope, token_store)

user_id = "default"
url = authorizer.get_authorization_url(base_url: "urn:ietf:wg:oauth:2.0:oob")

puts "\n1. Go to this URL in your browser:\n#{url}"
puts "\n2. Log in and allow permissions."
puts "3. Copy the 'Authorization Code' provided."

print "\nEnter Authorization Code: "
code = gets.chomp

credentials = authorizer.get_and_store_credentials_from_code(user_id: user_id, code: code, base_url: "urn:ietf:wg:oauth:2.0:oob")

puts "\n--- SUCCESS! ---"
puts "Add this to your .env file:"
puts "GOOGLE_DRIVE_REFRESH_TOKEN=#{credentials.refresh_token}"
puts "----------------"
