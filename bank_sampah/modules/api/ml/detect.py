#!/usr/bin/env python3
# Script Inferensi ML (YOLO ONNX) untuk mendeteksi sampah
# Usage: python detect.py /path/to/image.jpg
# Mengembalikan JSON: {"labels": ["label1", "label2"]}

import sys
import json
import os

def print_result_and_exit(labels):
    print(json.dumps({"labels": labels}))
    sys.exit(0)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print_result_and_exit([])
        
    image_path = sys.argv[1]
    
    if not os.path.exists(image_path):
        print_result_and_exit([])

    try:
        # Menggunakan package ultralytics karena sangat mendukung format YOLO ke ONNX
        from ultralytics import YOLO
    except ImportError:
        # Menulis error ke stderr agar PHP tidak menganggapnya sebagai output JSON yang valid
        sys.stderr.write("Error: Package 'ultralytics' belum terinstal. Jalankan 'pip install ultralytics'.\n")
        print_result_and_exit([])

    # Pastikan file model berada di folder yang sama dengan skrip ini
    model_path = os.path.join(os.path.dirname(__file__), 'best.onnx')
    
    if not os.path.exists(model_path):
        sys.stderr.write(f"Error: Model file tidak ditemukan di {model_path}\n")
        print_result_and_exit([])

    try:
        # Meload model ONNX
        model = YOLO(model_path, task='detect')
        
        # Melakukan prediksi
        results = model(image_path, verbose=False)
        
        detected_labels = []
        for r in results:
            boxes = r.boxes
            for box in boxes:
                # Mengambil ID class dan mengubahnya menjadi nama class
                cls_id = int(box.cls[0].item())
                label_name = model.names[cls_id]
                detected_labels.append(label_name)
                
        # Mengembalikan unique labels yang terdeteksi
        unique_labels = list(set(detected_labels))
        print_result_and_exit(unique_labels)
        
    except Exception as e:
        sys.stderr.write(f"Error saat inferensi: {e}\n")
        print_result_and_exit([])
