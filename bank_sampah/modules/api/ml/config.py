import os

# Set environment variable APP_ENV externally, or default to development
APP_ENV = os.getenv("APP_ENV", "production")

if APP_ENV == "development":
    SERVER_HOST = "127.0.0.1"
    SERVER_PORT = 5001
    SERVER_URL = f"http://{SERVER_HOST}:{SERVER_PORT}"
    UPLOAD_PATH = "../../assets/uploads/"
    API_ENDPOINT = "http://192.168.110.62/tugasakhirsampah/bank_sampah/modules/api/"
else:
    SERVER_HOST = "127.0.0.1"
    SERVER_PORT = 5001
    SERVER_URL = f"http://{SERVER_HOST}:{SERVER_PORT}"
    UPLOAD_PATH = "../../assets/uploads/"
    API_ENDPOINT = "https://itrashy.triki.cloud/modules/api/"
