#!/usr/bin/env bash
# ============================================================
#  start_worker.sh — Menjalankan iTrashy YOLO Detection Worker
#  Untuk VPS / Linux production.
#  
#  Penggunaan:
#    chmod +x start_worker.sh
#    ./start_worker.sh          # foreground
#    nohup ./start_worker.sh &  # background
#
#  Untuk systemd (direkomendasikan untuk produksi):
#    Lihat bagian komentar di bawah.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKER="$SCRIPT_DIR/detect_worker.py"
PORT=5001
LOG="$SCRIPT_DIR/worker.log"

# Pilih Python: .venv > python3 > python
VENV_PYTHON="$SCRIPT_DIR/../../../../.venv/bin/python"
if [ -f "$VENV_PYTHON" ]; then
    PYTHON="$VENV_PYTHON"
elif command -v python3 &>/dev/null; then
    PYTHON="python3"
else
    PYTHON="python"
fi

echo "[iTrashy Worker] Menggunakan: $PYTHON"
echo "[iTrashy Worker] Memulai di port $PORT, log: $LOG"

exec "$PYTHON" "$WORKER" --port "$PORT"

# ============================================================
# Contoh konfigurasi systemd untuk VPS (/etc/systemd/system/itrash-worker.service):
#
# [Unit]
# Description=iTrashy YOLO Detection Worker
# After=network.target
#
# [Service]
# Type=simple
# User=www-data
# WorkingDirectory=/var/www/tugasakhirsampah/bank_sampah/modules/api/ml
# ExecStart=/usr/bin/python3 /var/www/tugasakhirsampah/bank_sampah/modules/api/ml/detect_worker.py --port 5001
# Restart=always
# RestartSec=5
# StandardOutput=journal
# StandardError=journal
#
# [Install]
# WantedBy=multi-user.target
#
# Aktifkan dengan:
#   systemctl enable itrash-worker
#   systemctl start itrash-worker
# ============================================================
