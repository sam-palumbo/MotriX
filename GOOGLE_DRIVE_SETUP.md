# Google Drive Integration Setup Guide

This guide explains how to set up Google Drive API integration for file uploads in MotriX.

## Overview

The Google Drive integration allows users to upload documents, photos, and other files directly to Google Drive from the vehicle management interface. Files are associated with vehicles and optionally with events.

## Prerequisites

- Google Cloud Platform account
- A Google Drive folder for storing uploaded files
- Access to MotriX environment variables

## Project Approach

MotriX uses **Google Drive Service Account** authentication for file uploads. This means:
- Files are uploaded to a dedicated Google Drive folder using a service account (not your personal account)
- No OAuth flow or refresh tokens required for server-to-server uploads
- Credentials are stored as a JSON key file
- All team members upload to the same Drive folder

### Quick Setup (Using Scratch Scripts)

We have helper scripts in `scratch/` directory:

1. **`scratch/generate_json.rb`** - Creates the service account JSON file
2. **`scratch/test_google_drive.rb`** - Tests the upload connection
3. **`scratch/get_refresh_token.rb`** - For OAuth approach (alternative)

---

## Setup Steps

### Option A: Service Account (Recommended for Teams)

#### 1. Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Drive API:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Google Drive API"
   - Click "Enable"

### 2. Create a Service Account

1. Go to "IAM & Admin" > "Service Accounts"
2. Click "Create Service Account"
3. Enter a name (e.g., "motrix-drive-service")
4. Grant roles:
   - **Basic** > **Editor** (or create a custom role with Drive permissions)
5. Click "Create"

### 3. Generate Service Account Key

1. Click on the newly created service account
2. Go to the "Keys" tab
3. Click "Add Key" > "Create New Key"
4. Select "JSON" format
5. Click "Create" - this downloads the key file

### 4. Configure Environment Variables

1. Rename the downloaded JSON key file to `google_drive_service_account.json`
2. Place it in the `config/` directory
3. Update the environment variables in `.env` (Optional if you use the default path above):
   ```
   # Option A: Path to the JSON file
   GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY=config/google_drive_service_account.json
   
   # Option B: Paste the entire JSON content directly
   GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY='{"type": "service_account", ...}'
   ```

#### 5. Create Google Drive Folder (Recommended)

1. Go to [Google Drive](https://drive.google.com)
2. Create a folder for MotriX uploads (e.g., "MotriX - Documentos")
3. Share the folder with the service account email:
   - Right-click the folder > "Share"
   - Add the service account email (found in the JSON key file, e.g., `motrixserviceaccount@motrixuploadedfiles.iam.gserviceaccount.com`)
   - Grant "Editor" permissions
4. Get the Folder ID from the URL:
   - URL format: `https://drive.google.com/drive/folders/FOLDER_ID`
   - Copy the FOLDER_ID part
5. Add to `.env`:
   ```
   GOOGLE_DRIVE_VEICULOS_FOLDER_ID=your_folder_id_here
   ```

#### 6. Test the Connection

Run the test script to verify everything works:

```bash
ruby scratch/test_google_drive.rb
```

Expected output:
```
Testing Google Drive connection...
SUCCESS! File uploaded.
File ID: 1xxxxx...
View URL: https://drive.google.com/file/d/1xxxxx.../view?usp=drivesdk
```

Check your Google Drive folder - you should see the test file!

---

### Option B: OAuth2 (Personal Google Account)

Use this if you want uploads to go to your personal Google Drive using your storage quota.

This is better for personal `@gmail.com` accounts because it uses your own storage quota.

1.  **Create OAuth Credentials**:
    *   Go to **APIs & Services > Credentials**.
    *   Click **+ Create Credentials > OAuth client ID**.
    *   Select **Application type: Desktop app**.
    *   Copy the **Client ID** and **Client Secret**.
2.  **Generate Refresh Token**:
    *   Run this script in your terminal:
      ```bash
      ruby scratch/get_refresh_token.rb
      ```
    *   Follow the instructions to log in and get your **Refresh Token**.
3.  **Update `.env`**:
    ```env
    GOOGLE_DRIVE_CLIENT_ID=your_client_id
    GOOGLE_DRIVE_CLIENT_SECRET=your_client_secret
    GOOGLE_DRIVE_REFRESH_TOKEN=your_refresh_token
    GOOGLE_DRIVE_VEICULOS_FOLDER_ID=your_folder_id
    ```

### 6. Test the Integration

1. Ensure the test script passed (see above)
2. Start the Rails server:
   ```bash
   rails server
   ```
3. Navigate to a vehicle page
4. Try uploading a document using the "Adicionar Documento" form
5. Or create a New Evento with file attachments

## Features

### Current Implementation

- **File Upload**: Upload documents directly to Google Drive
- **File Types Supported**: PDF, DOC, DOCX, JPG, PNG, GIF, ZIP, RAR
- **Categories**: Documento, Foto, Contrato, Nota Fiscal, Outros
- **File Management**: View uploaded files with direct Google Drive links
- **File Deletion**: Remove files from both database and Google Drive

### Data Structure

Files are stored with the following information:
- `nome_arquivo`: Original filename
- `arquivo_url`: Google Drive view/share URL
- `mime_type`: File MIME type
- `categoria`: Document category
- `veiculo_id`: Associated vehicle
- `evento_id`: Optional associated event

### Security

- Files are uploaded using a dedicated service account
- Service account credentials are not exposed in the codebase
- File permissions can be configured (currently set to public readable)
- File deletion removes both the database record and Google Drive file

## Troubleshooting

### Common Issues

1. **"Unauthorized" error**:
   - Check that the service account key file exists at the configured path
   - Verify the Google Drive API is enabled in Google Cloud Console
   - Ensure the service account has proper permissions

2. **Files not appearing in Google Drive**:
   - Check that the folder ID is correct
   - Verify the service account has access to the folder
   - Check Rails logs for detailed error messages

3. **Upload fails silently**:
   - Check browser console for JavaScript errors
   - Verify file size limits (default: 50MB)
   - Check Rails logs in `log/development.log`

### Logs

Check these locations for debugging:
- Rails logs: `log/development.log` or `log/production.log`
- Google Drive API errors appear in Rails logs with prefix "Google Drive"

## Production Deployment

For production environments:

1. **Environment Variables**:
   - Set `GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY` to the path of your production key file
   - Or set it to the JSON content directly (for cloud platforms)
   - Set `GOOGLE_DRIVE_VEICULOS_FOLDER_ID` to a dedicated production folder

2. **Security**:
   - Never commit the service account key file to version control
   - Add `config/google_drive_service_account.json` to `.gitignore`
   - Use environment-specific keys for different environments

3. **File Storage**:
   - Monitor Google Drive storage quotas
   - Consider implementing file size limits per user/vehicle
   - Implement retention policies if needed

## Advanced Configuration

### Custom File Permissions

By default, uploaded files are made publicly readable. To change this, modify the `upload_file` method in `app/services/google_drive_service.rb`:

```ruby
# Remove or modify this line to change permissions
uploaded_file.acl.push({ type: "anyone", role: "reader" })

# For private files (only accessible by service account):
# uploaded_file.acl.push({ type: "user", role: "reader", value: "user@example.com" })
```

### Custom Folder Structure

To create subfolders per vehicle:

```ruby
# In AnexosController#create, modify the folder logic:
folder_name = "Veiculo_#{@veiculo.placa}"
upload_result = drive_service.upload_file(
  arquivo,
  folder_id: drive_service.create_folder(folder_name)[:folder_id],
  file_name: arquivo.original_filename
)
```

## Migration Notes

If migrating from another storage solution:

1. Existing `arquivo_url` values should remain valid
2. New uploads will go to Google Drive
3. Consider a migration script to move existing files

## Scratch Scripts Reference

The `scratch/` directory contains utility scripts for Google Drive setup:

### `scratch/generate_json.rb`
Creates the service account JSON credentials file programmatically. 
- **Usage**: `ruby scratch/generate_json.rb`
- **Output**: Creates `config/google_drive_service_account.json`
- **Note**: Contains embedded credentials - run once to generate the file

### `scratch/test_google_drive.rb`
Tests the Google Drive connection and uploads a test file.
- **Usage**: `ruby scratch/test_google_drive.rb`
- **Output**: Confirms successful upload with File ID and View URL
- **Use this first** to verify your setup works before using the web interface

### `scratch/get_refresh_token.rb`
For OAuth2 personal account setup (alternative to service account).
- **Usage**: `ruby scratch/get_refresh_token.rb`
- **Purpose**: Gets refresh token for personal Google Drive access
- **Note**: Only needed if using OAuth2 approach instead of service account

---

## Support

For issues specific to the Google Drive integration:
- Check [Google Drive API documentation](https://developers.google.com/drive/api/v3/about-sdk)
- Review the `GoogleDriveService` class in `app/services/google_drive_service.rb`
- Check Rails logs for detailed error messages
