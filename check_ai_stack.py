
import sys
import importlib.metadata as metadata

print("=== UAV AI Environment Diagnostic ===")
print("Python:", sys.version)
print("Interpreter:", sys.executable)

packages = [
    "torch",
    "torchvision",
    "torchaudio",
    "opencv-python",
    "opencv-python-headless",
    "ultralytics",
    "onnxruntime-gpu",
    "numpy",
]

for package in packages:
    try:
        print(f"{package}: {metadata.version(package)}")
    except metadata.PackageNotFoundError:
        print(f"{package}: not installed")

print("\n=== PyTorch / CUDA ===")
try:
    import torch

    print("PyTorch:", torch.__version__)
    print("CUDA build:", torch.version.cuda)
    print("CUDA available:", torch.cuda.is_available())

    if torch.cuda.is_available():
        x = torch.randn(512, 512, device="cuda")
        y = x @ x
        torch.cuda.synchronize()
        print("GPU matrix multiplication: PASS")

except Exception as exc:
    print("PyTorch diagnostic FAILED:", repr(exc))

print("\n=== Torchvision ===")
try:
    import torchvision
    from torchvision.ops import nms

    boxes = torch.tensor(
        [[0, 0, 10, 10], [1, 1, 9, 9]],
        dtype=torch.float32,
        device="cuda" if torch.cuda.is_available() else "cpu",
    )
    scores = torch.tensor(
        [0.9, 0.8], device=boxes.device
    )
    print("Torchvision:", torchvision.__version__)
    print("NMS operation:", nms(boxes, scores, 0.5))
    print("Torchvision operations: PASS")
except Exception as exc:
    print("Torchvision diagnostic FAILED:", repr(exc))

print("\n=== OpenCV ===")
try:
    import cv2
    print("OpenCV runtime:", cv2.__version__)
    print("OpenCV import: PASS")
except Exception as exc:
    print("OpenCV diagnostic FAILED:", repr(exc))

print("\n=== ONNX Runtime ===")
try:
    import onnxruntime as ort
    print("ONNX Runtime:", ort.__version__)
    print("Available providers:", ort.get_available_providers())
except Exception as exc:
    print("ONNX Runtime diagnostic FAILED:", repr(exc))

print("\n=== Ultralytics ===")
try:
    import ultralytics
    print("Ultralytics:", ultralytics.__version__)
except Exception as exc:
    print("Ultralytics diagnostic FAILED:", repr(exc))
