#!/usr/bin/env python3
# Simple stub for ML detection (YOLO) — for development only.
# Usage: python detect.py /path/to/image.jpg
# Outputs JSON: {"labels": ["label1", "label2"]}

import sys
import json
import os
import random

# If you have a real YOLO model, replace this script with proper inference code.
SAMPLE_LABELS = [
    "Plastik Botol (PET)",
    "Kardus",
    "Kertas HVS/Buku",
    "Logam (Besi)",
    "Logam (Aluminium)",
    "Gelas Plastik (PP)"
]

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(json.dumps({"labels": []}))
        sys.exit(0)
    image_path = sys.argv[1]
    # Very naive: pick 1-2 random labels to simulate detection
    labels = random.sample(SAMPLE_LABELS, k=random.randint(1,2))
    print(json.dumps({"labels": labels}))
