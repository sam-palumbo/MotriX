# frozen_string_literal: true

require "google_drive"
require "ostruct"

class GoogleDriveService
  def initialize
    client_id = ENV["GOOGLE_DRIVE_CLIENT_ID"]
    client_secret = ENV["GOOGLE_DRIVE_CLIENT_SECRET"]
    refresh_token = ENV["GOOGLE_DRIVE_REFRESH_TOKEN"]

    if client_id && client_secret && refresh_token
      config = OpenStruct.new({
        client_id: client_id,
        client_secret: client_secret,
        refresh_token: refresh_token,
        scope: [ "https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/drive.file" ]
      })
      @session = GoogleDrive::Session.from_config(config)
    else
      # Fallback to service account if still configured
      key = ENV["GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY"] || Rails.root.join("config", "google_drive_service_account.json").to_s

      if key.is_a?(String) && key.start_with?("{")
        @session = GoogleDrive::Session.from_service_account_key(StringIO.new(key))
      elsif key && (key.is_a?(String) || key.is_a?(Pathname)) && File.exist?(key.to_s)
        @session = GoogleDrive::Session.from_service_account_key(key.to_s)
      else
        raise "Missing Google Drive credentials. Please provide GOOGLE_DRIVE_CLIENT_ID, CLIENT_SECRET, and REFRESH_TOKEN (Option B) OR a Service Account JSON (Option A)."
      end
    end
  end

  def upload_file(file, folder_id: nil, file_name: nil)
    file_name ||= file.original_filename

    # Create or get folder
    folder = get_or_create_folder(folder_id)

    # Upload file
    uploaded_file = folder.upload_from_file(file.path, file_name, convert: false)

    # Make file publicly readable (optional - can be configured)
    uploaded_file.acl.push({ type: "anyone", role: "reader" })

    {
      file_id: uploaded_file.id,
      file_url: uploaded_file.web_content_link,
      view_url: uploaded_file.web_view_link,
      file_name: file_name,
      mime_type: uploaded_file.mime_type,
      size: uploaded_file.size
    }
  rescue StandardError => e
    Rails.logger.error "Google Drive upload failed: #{e.message}"
    raise e
  end

  def delete_file(file_id)
    file = @session.file_by_id(file_id)
    file.delete
  rescue StandardError => e
    Rails.logger.error "Google Drive delete failed: #{e.message}"
    raise e
  end

  def update_file(file_id, new_file)
    old_file = @session.file_by_id(file_id)
    folder = old_file.parents.first

    # Delete old file
    old_file.delete

    # Upload new file
    upload_file(new_file, folder_id: folder.id, file_name: new_file.original_filename)
  rescue StandardError => e
    Rails.logger.error "Google Drive update failed: #{e.message}"
    raise e
  end

  def create_folder(name, parent_folder_id: nil)
    if parent_folder_id
      parent = @session.file_by_id(parent_folder_id)
      folder = parent.create_subfolder(name)
    else
      folder = @session.root_collection.create_subfolder(name)
    end

    { folder_id: folder.id, folder_name: folder.title }
  rescue StandardError => e
    Rails.logger.error "Google Drive folder creation failed: #{e.message}"
    raise e
  end

  private

  def get_or_create_folder(folder_id)
    if folder_id
      @session.file_by_id(folder_id)
    else
      # Use default folder or root
      default_folder_id = ENV["GOOGLE_DRIVE_DEFAULT_FOLDER_ID"]
      default_folder_id ? @session.file_by_id(default_folder_id) : @session.root_collection
    end
  end
end
