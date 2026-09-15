# UAV AI Setup

Reusable Windows/VS Code environment bootstrap for NVIDIA CUDA development, PyTorch GPU AI training, computer vision, UAV simulation/robotics, PX4/MAVLink/MAVSDK, and multi-agent/swarm simulation research.

## Quick start

Open PowerShell in this repository:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup_windows.ps1 -Profile FULL
```

Then:

```powershell
conda activate uav-ai
python .\verify_gpu.py
nvidia-smi
nvcc --version
```

## Profiles

- `AI` — PyTorch, scientific Python, Jupyter, TensorBoard
- `VISION` — AI + OpenCV/YOLO/image tooling
- `UAV` — AI + MAVLink/MAVSDK helpers
- `SWARM-SIM` — AI + simulation/research packages
- `FULL` — all Python components

System-level NVIDIA drivers, CUDA Toolkit, and Visual Studio C++ tools are intentionally not replaced silently by the installer. Verify versions on each PC.

For reproducibility after a successful setup:

```powershell
conda env export --from-history > environment-history.yml
pip freeze > requirements-lock.txt
```

For real aircraft, develop and validate in simulation/SITL first and follow applicable aviation and safety requirements. This repository is for development, research, and simulation and does not implement autonomous weapon targeting or engagement logic.
