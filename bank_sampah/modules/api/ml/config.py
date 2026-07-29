import os

# Set environment variable APP_ENV externally, or default to development
APP_ENV = os.getenv("APP_ENV", "production")

if APP_ENV == "development":
    SERVER_HOST = "0.0.0.0"
    SERVER_PORT = 5001
    SERVER_URL = f"http://192.168.111.14:{SERVER_PORT}"
    UPLOAD_PATH = "../../assets/uploads/"
    API_ENDPOINT = "http://192.168.111.14/tugasakhirsampah/bank_sampah/modules/api/"
else:
    SERVER_HOST = "0.0.0.0"
    SERVER_PORT = 5001
    SERVER_URL = f"http://192.168.111.14:{SERVER_PORT}"
    UPLOAD_PATH = "../../assets/uploads/"
    API_ENDPOINT = "http://192.168.111.14/tugasakhirsampah/bank_sampah/modules/api/"
