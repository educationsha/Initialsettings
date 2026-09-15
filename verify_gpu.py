import shutil
import subprocess
import sys

print("=== UAV AI GPU Verification ===")
print("\nPython:")
print(sys.version)

print("\nnvidia-smi:")
if shutil.which("nvidia-smi"):
    subprocess.run(["nvidia-smi", "--query-gpu=name,driver_version,memory.total", "--format=csv"])
else:
    print("NOT FOUND")

print("\nnvcc:")
if shutil.which("nvcc"):
    subprocess.run(["nvcc", "--version"])
else:
    print("NOT FOUND (system CUDA Toolkit compiler)")

try:
    import torch
    print("\nPyTorch:", torch.__version__)
    print("PyTorch CUDA build:", torch.version.cuda)
    print("CUDA available:", torch.cuda.is_available())
    if torch.cuda.is_available():
        print("GPU:", torch.cuda.get_device_name(0))
        print("GPU count:", torch.cuda.device_count())
        x = torch.randn((4096, 4096), device="cuda")
        y = x @ x
        torch.cuda.synchronize()
        print("GPU tensor test: PASS")
        print("Result mean:", y.mean().item())
    else:
        print("GPU tensor test: SKIPPED")
except Exception as exc:
    print("PyTorch verification failed:", repr(exc))
    raise
