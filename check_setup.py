import shutil
import subprocess
import sys


def run(cmd):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, check=False)
    except Exception as exc:
        return None

print("=" * 60)
print("        UAV AI / CUDA SETUP CHECK")
print("=" * 60)

print("\n[Python]")
print(f"Version : {sys.version.split()[0]}")
print(f"Path    : {sys.executable}")
print("PASS - Python 3.11" if sys.version_info[:2] == (3, 11) else "WARNING - Expected Python 3.11")

print("\n[NumPy]")
try:
    import numpy
    print(f"Version : {numpy.__version__}")
    print("PASS - NumPy installed")
except Exception as exc:
    print(f"FAIL - {exc}")

print("\n[PyTorch]")
try:
    import torch
    print(f"Version      : {torch.__version__}")
    print(f"CUDA build   : {torch.version.cuda}")
    if torch.cuda.is_available():
        print("CUDA available: TRUE")
        print(f"GPU          : {torch.cuda.get_device_name(0)}")
        x = torch.tensor([1.0, 2.0, 3.0], device="cuda")
        print(f"GPU test     : {(x * 2).tolist()}")
        print("PASS - RTX GPU working")
    else:
        print("FAIL - CUDA not available")
except Exception as exc:
    print(f"FAIL - PyTorch error: {exc}")

print("\n[NVIDIA]")
if shutil.which("nvidia-smi"):
    result = run(["nvidia-smi", "--query-gpu=name,driver_version,memory.total", "--format=csv,noheader"])
    print(result.stdout.strip() if result else "Unable to run nvidia-smi")
    print("PASS - NVIDIA driver detected" if result and result.returncode == 0 else "FAIL - nvidia-smi failed")
else:
    print("FAIL - nvidia-smi not found")

print("\n[CUDA Toolkit]")
if shutil.which("nvcc"):
    result = run(["nvcc", "--version"])
    if result:
        for line in result.stdout.splitlines():
            if "release" in line:
                print(line.strip())
    print("PASS - nvcc detected")
else:
    print("WARNING - nvcc not found (only required for CUDA C/C++ development)")

print("\n[Computer Vision]")
try:
    import cv2
    print(f"OpenCV : {cv2.__version__}")
    print("PASS - OpenCV installed")
except Exception as exc:
    print(f"WARNING - OpenCV not installed: {exc}")

print("\n" + "=" * 60)
print("              SETUP CHECK COMPLETE")
print("=" * 60)
