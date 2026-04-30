require 'json'
data = {
  type: "service_account",
  project_id: "motrixuploadedfiles",
  private_key_id: "6f2921bda8b7b65a9702611b2fa2ffa2a3d7569e",
  private_key: "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDeqxb+W2hsEuvk\nuvvTu18OJ6tsiMj3ManB+9Tjg87WuxVTBXLIjkRMhyNWwVelrb1AsXWsb19NwTpC\n/KEldjEK2e9RPWR+ALrU6dDQA2/2PxOvrrofVWj95MeFbm6kUrd1Sc7reyD+zi3r\nc7aEYViwSDLFu+QvHlO9zryMw9kyD+AOg4+FA13BUWaXkg7XaddJW7y/mmftgh1/\nxCsCPvQLAKn5EahHtiKSn7bC6Vv6xobglcThHkSFdPBC0rHJ2Ft6wb3Dk0kh6tTR\nt2kANB2/EF80KZWHjBotzqmU+lQbl5qTOEKLHJoQyvHkg6E0R4cAqIzUdieEXW7/\nUmX6s6PzAgMBAAECggEAZ/HDSpreLLFKiFyXSThrP77aAdD6y5ZV8jW+pDS4Hjp4\nUmi1NBVhob3mC842vaNUuPn+fjABc9kzeujWyxeY/kFNPAXmPwHVNaYusaQhJHk+\nleEBhrYGzJr7Xvj10mTAupJpczjn5rrV6dd7COIuliAl/3NeKnbETdNP5oBYiErM\nmpLXC8cnStJa4leOsi2iRWCvMUoOqko/wx0xIrolpMKEYvbi0/rovrq7kIk0YY2v\nitJvDtYEa0O7iGu8n2D1Q9r+Ug8C6tlYw7TIspK+PLwYxJeKx3thPmj3OI6lf+sG\nK4jrh4bhccM2svTwACstIujn2hPBRqqWGOQty+3e+QKBgQD9ClK86upN90NX/AU9\nssQXct5/i+Ph4tFZ5LTpYVZI7LDev3sSVA2TdD5+KVscNHuMs0B2dV20JrjX8Hxf\nLqHaSnOfUTFYjIJn/uNdn/pI4QMUnZhyWOTklwG3wSdu63qMkE3JE7iZQuUN1xYf\niApqmvLnFIP8LMwH9wqdmuGRWwKBgQDhRdLuTXKADlKCD4DGgGSxxG6QyK2xGGbe\nIOlBkhZOtI7nCiYg6aG//mgY0iYiMkue6vsk9vD/rzXwqlbIVO9yxtf+WPeBgJuI\n3ADQG6cA4/k4oAc/95zZHk15Cca4O0A2FZEkwnm/QQZiHsKv0xBUATZIh0/W7sES\nUjp7BHFjSQKBgQDd7J3f/o/8TS4NDoVyNUTx49bsOj5ksE837fQU8z9/ucbttTY1\ Pu6hMkRU1eSIeicZoWSaABlslMFs8gfCWt2s27tIMSd8J89/cfbq+BHEtUPEYut+\n7iPhr+bbyFXTXEcg3La78cXm9Np7JvbKNMAd+0OqEz4mfwt6uNngnCPVHQKBgQDO\nSrHJllSnXfZCsk27+bG8dOTHY25jwbPZ8IuKh2w0MPa4LrwR4cFE34WWTUOshyBm\n7EqGZDj3/AxKUsLb+6O3GM6NVg15oztLTiTUbq41i48bQrjA5FDXJv/NOp2m8mNv\n47ohzpHNCY/95KtmdcL7Go0KSBdd/RADZhe1tbDcOQKBgCSAZY3tXMbfVNnX9BFa\nUy06lk2RzYLZEeFtxzMcA5JKhKyKPVpBiq7E9tMsS7VqAm9rHpLwfEEju8rfMMWq\nwQYA70ycJzSJAfAisoh6XzuttYuaLwws4P+Hfv3F8fifUZSghwIvohifvVDGYRV2\ni36mxUcqoDiL8QPvUc9cW+9y\n-----END PRIVATE KEY-----\n",
  client_email: "motrixserviceaccount@motrixuploadedfiles.iam.gserviceaccount.com",
  client_id: "107004486372753015564",
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/motrixserviceaccount%40motrixuploadedfiles.iam.gserviceaccount.com",
  universe_domain: "googleapis.com"
}
File.write("config/google_drive_service_account.json", JSON.pretty_generate(data))
puts "JSON written successfully"
