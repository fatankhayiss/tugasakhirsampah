@echo off
REM ============================================================
REM  start_worker.bat — Menjalankan iTrashy YOLO Detection Worker
REM  Inference engine: ONNX Runtime (onnxruntime)
REM  Dependencies: pip install onnxruntime opencv-python-headless numpy
REM
REM  Gunakan ini di Laragon/Windows saat development.
REM  Untuk produksi VPS, gunakan start_worker.sh dengan systemd.
REM ============================================================

SET SCRIPT_DIR=%~dp0
SET VENV_PYTHON=%SCRIPT_DIR%..\..\..\..\.venv\Scripts\python.exe
SET WORKER=%SCRIPT_DIR%detect_worker.py
SET PORT=5001

echo [iTrashy Worker] Memulai detection worker di port %PORT%...

REM Coba pakai .venv dulu, fallback ke python global
IF EXIST "%VENV_PYTHON%" (
    echo [iTrashy Worker] Menggunakan .venv: %VENV_PYTHON%
    "%VENV_PYTHON%" "%WORKER%" --port %PORT%
) ELSE (
    echo [iTrashy Worker] .venv tidak ditemukan, menggunakan python global...
    python "%WORKER%" --port %PORT%
)

pause
