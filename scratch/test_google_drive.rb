require_relative "../config/environment"

begin
  puts "Testing Google Drive connection..."
  service = GoogleDriveService.new
  
  temp_file = Tempfile.new(["test_upload", ".txt"])
  temp_file.write("Hello from MotriX! This is a test upload at #{Time.current}")
  temp_file.rewind
  
  # Mocking a Rack::Test::UploadedFile or similar object structure that the service expects
  mock_file = Struct.new(:path, :original_filename).new(temp_file.path, "motrix_test_upload.txt")
  
  result = service.upload_file(mock_file)
  puts "SUCCESS! File uploaded."
  puts "File ID: #{result[:file_id]}"
  puts "View URL: #{result[:view_url]}"
rescue => e
  puts "FAILED: #{e.message}"
  puts e.backtrace.first(5)
ensure
  temp_file&.close
  temp_file&.unlink
end
