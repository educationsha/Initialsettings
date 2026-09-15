# CUDA on Windows

For RTX 4070-class systems:

1. Install a current NVIDIA driver.
2. Install the NVIDIA CUDA Toolkit when you need `nvcc` and CUDA C/C++ development.
3. Install Visual Studio/Build Tools with the MSVC C++ workload.
4. Restart PowerShell.
5. Verify with `nvidia-smi` and `nvcc --version`.

Do not assume the system CUDA Toolkit version must equal the CUDA runtime used by PyTorch. PyTorch publishes supported CUDA wheels separately.

Official references:
- NVIDIA CUDA Windows guide: https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/
- PyTorch installer: https://pytorch.org/get-started/locally/
