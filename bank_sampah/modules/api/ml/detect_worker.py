#!/usr/bin/env python3
"""
detect_worker.py — Persistent YOLO ONNX inference worker for iTrashy.

Architecture:
  PHP (detect.php) ──socket──> this worker ──> best.onnx (loaded once)

Protocol (newline-delimited JSON over TCP):
  Request:  {"image_path": "/abs/path/to/image.jpg"}\n
  Response: {"success": true, "labels": ["Plastik Botol", "Kardus"]}\n
  Error:    {"success": false, "error": "reason"}\n

Inference engine: ONNX Runtime (onnxruntime)
  - No ultralytics dependency
  - Loads best.onnx once at startup
  - Manual image preprocessing + NMS
  - Lighter RAM footprint, VPS-friendly

Install:
  pip install onnxruntime opencv-python-headless numpy

Run:
  python detect_worker.py                    # default: 127.0.0.1:5001
  python detect_worker.py --port 5001

Stop:
  CTRL+C   or   kill <pid>   (graceful shutdown via SIGINT/SIGTERM)
"""

import os
import sys
import json
import signal
import socket
import logging
import argparse
import threading
from pathlib import Path

# ─────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────
WORKER_HOST  = "127.0.0.1"
WORKER_PORT  = 5001
BACKLOG      = 10
LOG_FILE     = Path(__file__).parent / "worker.log"
MODEL_PATH   = Path(__file__).parent / "best.onnx"
CONFIDENCE   = 0.25   # Minimum detection confidence threshold
MAX_IMG_SIZE = 640    # YOLO input size

# ─────────────────────────────────────────────
# Logging — file only, never stdout
# PHP communicates via socket, not subprocess stdout.
# ─────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE, encoding="utf-8"),
    ],
)
log = logging.getLogger("detect_worker")

# ─────────────────────────────────────────────
# Global model state — loaded ONCE at startup
# ─────────────────────────────────────────────
_session    = None   # onnxruntime.InferenceSession
_class_names: list[str] = []
_input_name  = ""
_input_shape = (640, 640)   # (height, width)
_model_lock  = threading.Lock()


def load_model():
    """
    Load YOLO ONNX model with ONNX Runtime.
    Extracts class names from ONNX model metadata.
    Called once at startup — model stays in RAM forever.
    """
    global _session, _class_names, _input_name, _input_shape

    if not MODEL_PATH.exists():
        log.error(f"Model tidak ditemukan: {MODEL_PATH}")
        sys.exit(1)

    log.info(f"Memuat model dengan ONNX Runtime dari: {MODEL_PATH}")

    # ── Import dependencies ────────────────────
    try:
        import onnxruntime as ort
    except ImportError:
        log.error(
            "Package 'onnxruntime' belum terinstal. "
            "Jalankan: pip install onnxruntime opencv-python-headless numpy"
        )
        sys.exit(1)

    try:
        import numpy as np  # noqa: F401 — verify it's available at startup
    except ImportError:
        log.error("Package 'numpy' belum terinstal. Jalankan: pip install numpy")
        sys.exit(1)

    try:
        import cv2  # noqa: F401 — verify at startup
    except ImportError:
        log.error(
            "Package 'opencv-python-headless' belum terinstal. "
            "Jalankan: pip install opencv-python-headless"
        )
        sys.exit(1)

    # ── Load InferenceSession ──────────────────
    try:
        # Prefer CPU provider only for VPS compatibility
        providers = ["CPUExecutionProvider"]
        sess_opts = ort.SessionOptions()
        sess_opts.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
        sess_opts.intra_op_num_threads = 2   # Keep CPU usage bounded on VPS

        _session = ort.InferenceSession(
            str(MODEL_PATH),
            sess_options=sess_opts,
            providers=providers,
        )
    except Exception as exc:
        log.error(f"Gagal membuat InferenceSession: {exc}")
        sys.exit(1)

    # ── Extract input metadata ─────────────────
    inp = _session.get_inputs()[0]
    _input_name = inp.name
    shape = inp.shape   # e.g. [1, 3, 640, 640]
    if len(shape) == 4 and isinstance(shape[2], int) and isinstance(shape[3], int):
        _input_shape = (shape[2], shape[3])   # (height, width)
    log.info(f"Input: name='{_input_name}'  shape={shape}  using={_input_shape}")

    # ── Extract class names from ONNX metadata ─
    meta = _session.get_modelmeta()
    raw_names = meta.custom_metadata_map.get("names", "")
    if raw_names:
        try:
            # Ultralytics exports names as Python dict repr: {0: 'Plastik', 1: 'Kardus', ...}
            import ast
            parsed = ast.literal_eval(raw_names)
            if isinstance(parsed, dict):
                _class_names = [parsed[k] for k in sorted(parsed.keys())]
            elif isinstance(parsed, list):
                _class_names = parsed
        except Exception as e:
            log.warning(f"Gagal parse class names dari metadata: {e}. Raw: {raw_names[:200]}")

    if not _class_names:
        # Fallback: derive from output shape (num_classes = output_channels - 4)
        try:
            out = _session.get_outputs()[0]
            out_shape = out.shape
            # YOLOv8 ONNX: [1, 4+num_classes, num_anchors]
            if len(out_shape) == 3:
                num_cls = int(out_shape[1]) - 4
                _class_names = [f"class_{i}" for i in range(max(num_cls, 1))]
                log.warning(
                    f"Metadata class names tidak ditemukan. "
                    f"Menggunakan {len(_class_names)} placeholder names."
                )
        except Exception:
            _class_names = [f"class_{i}" for i in range(80)]
            log.warning("Menggunakan 80 COCO placeholder class names.")

    log.info(f"Class names ({len(_class_names)}): {_class_names[:10]}...")

    # ── Warm-up inference ─────────────────────
    try:
        import numpy as np
        dummy = np.zeros((1, 3, _input_shape[0], _input_shape[1]), dtype=np.float32)
        _session.run(None, {_input_name: dummy})
        log.info("Warm-up inference selesai. Worker siap.")
    except Exception as exc:
        log.warning(f"Warm-up gagal (tidak fatal): {exc}")


# ─────────────────────────────────────────────
# Inference
# ─────────────────────────────────────────────
def _preprocess(image_path: str) -> "numpy.ndarray":  # type: ignore[name-defined]
    """Load image and preprocess to YOLO input tensor [1, 3, H, W] float32 0..1."""
    import cv2
    import numpy as np

    img = cv2.imread(image_path)
    if img is None:
        raise ValueError(f"cv2 tidak dapat membaca gambar: {image_path}")

    h, w = _input_shape
    img_resized = cv2.resize(img, (w, h))
    img_rgb     = cv2.cvtColor(img_resized, cv2.COLOR_BGR2RGB)
    img_float   = img_rgb.astype(np.float32) / 255.0
    img_chw     = img_float.transpose(2, 0, 1)          # HWC → CHW
    img_batch   = np.expand_dims(img_chw, axis=0)        # CHW → NCHW
    return np.ascontiguousarray(img_batch)


def _postprocess(outputs, conf_threshold: float = CONFIDENCE) -> list[str]:
    """
    Decode YOLO ONNX output and return unique detected class names.

    YOLOv8 ONNX output shape: [1, 4+num_classes, num_anchors]
      - First 4 rows: cx, cy, w, h
      - Remaining rows: class scores (no objectness)
    """
    import numpy as np

    raw = outputs[0]          # shape [1, 4+C, N]
    raw = raw[0]              # shape [4+C, N]

    num_classes = len(_class_names)
    # Scores matrix: [N, C]
    scores = raw[4: 4 + num_classes, :].T    # [N, C]

    # For each anchor: max class score and which class
    max_scores = scores.max(axis=1)           # [N]
    class_ids  = scores.argmax(axis=1)        # [N]

    # Filter by confidence
    mask = max_scores >= conf_threshold
    detected_ids = class_ids[mask].tolist()

    # Unique labels, preserving first-seen order
    seen: set[int] = set()
    unique: list[str] = []
    for cid in detected_ids:
        if cid not in seen:
            seen.add(cid)
            label = _class_names[cid] if cid < len(_class_names) else f"class_{cid}"
            unique.append(label)

    return unique


def run_inference(image_path: str) -> list[str]:
    """Run ONNX Runtime inference on `image_path`. Returns list of unique label names."""
    if not os.path.isfile(image_path):
        raise FileNotFoundError(f"File gambar tidak ditemukan: {image_path}")

    tensor = _preprocess(image_path)

    with _model_lock:
        outputs = _session.run(None, {_input_name: tensor})

    return _postprocess(outputs)


# ─────────────────────────────────────────────
# Connection handler (one thread per connection)
# ─────────────────────────────────────────────
def handle_client(conn: socket.socket, addr):
    """Handle a single PHP client connection."""
    try:
        with conn:
            # Read request (up to 4KB, newline-terminated)
            data = b""
            while True:
                chunk = conn.recv(4096)
                if not chunk:
                    break
                data += chunk
                if b"\n" in data:
                    break

            raw = data.decode("utf-8", errors="replace").strip()
            if not raw:
                _send_json(conn, {"success": False, "error": "Empty request"})
                return

            try:
                req = json.loads(raw)
            except json.JSONDecodeError as e:
                _send_json(conn, {"success": False, "error": f"Invalid JSON: {e}"})
                return

            image_path = req.get("image_path", "")
            if not image_path:
                _send_json(conn, {"success": False, "error": "Missing image_path"})
                return

            log.info(f"Inferensi: {image_path}")
            labels = run_inference(image_path)
            log.info(f"Hasil: {labels}")
            _send_json(conn, {"success": True, "labels": labels})

    except FileNotFoundError as e:
        log.warning(str(e))
        _send_json(conn, {"success": False, "error": str(e)})
    except Exception as e:
        log.error(f"Error saat inferensi: {e}")
        try:
            _send_json(conn, {"success": False, "error": str(e)})
        except Exception:
            pass


def _send_json(conn: socket.socket, payload: dict):
    """Send newline-terminated JSON response."""
    try:
        msg = json.dumps(payload, ensure_ascii=False) + "\n"
        conn.sendall(msg.encode("utf-8"))
    except Exception:
        pass


# ─────────────────────────────────────────────
# Main server loop
# ─────────────────────────────────────────────
_shutdown = False


def shutdown_handler(signum, frame):
    global _shutdown
    log.info("Shutdown signal diterima. Menghentikan worker...")
    _shutdown = True


def run_server(host: str, port: int):
    global _shutdown

    signal.signal(signal.SIGINT,  shutdown_handler)
    signal.signal(signal.SIGTERM, shutdown_handler)

    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((host, port))
    srv.listen(BACKLOG)
    srv.settimeout(1.0)   # Allow checking _shutdown every second

    log.info(f"Worker siap menerima koneksi di {host}:{port}")

    while not _shutdown:
        try:
            conn, addr = srv.accept()
        except socket.timeout:
            continue
        except OSError:
            break

        t = threading.Thread(target=handle_client, args=(conn, addr), daemon=True)
        t.start()

    srv.close()
    log.info("Worker berhenti.")


# ─────────────────────────────────────────────
# Entry point
# ─────────────────────────────────────────────
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="iTrashy YOLO ONNX Detection Worker")
    parser.add_argument("--host", default=WORKER_HOST, help="Bind host (default: 127.0.0.1)")
    parser.add_argument("--port", type=int, default=WORKER_PORT, help="Bind port (default: 5001)")
    args = parser.parse_args()

    load_model()
    run_server(args.host, args.port)
