# UAV AI Setup

Reusable Windows/VS Code bootstrap for NVIDIA/RTX AI training, CUDA development, computer vision, UAV simulation/robotics, PX4/MAVLink/MAVSDK, and multi-agent/swarm simulation research.

## What this repo does

This repository is designed to be cloned onto a new NVIDIA/RTX Windows PC and used as a repeatable starting point. It installs Python-side dependencies into an isolated `uav-ai` Conda environment and verifies the GPU stack.

It does **not** silently install or replace system-level NVIDIA drivers, CUDA Toolkit, Visual Studio Build Tools, ROS 2, PX4, or Gazebo. Those components are version- and hardware-dependent, so follow the guides in this repository and verify them on each machine.

## New PC quick start

### 1. Install system prerequisites

Install these first:

- NVIDIA driver appropriate for the GPU
- Git for Windows
- Miniconda or Miniforge
- VS Code
- CUDA Toolkit only if you need CUDA C/C++ compilation (`nvcc`)
- Visual Studio C++ Build Tools when native compilation is required

Open a **new PowerShell** after installing prerequisites.

### 2. Clone the repository

```powershell
git clone https://github.com/educationsha/Initialsettings.git
cd Initialsettings
```

### 3. Allow this script for the current PowerShell session

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

### 4. Install a profile

```powershell
.\setup_windows.ps1 -Profile FULL
```

Available profiles:

- `AI` — PyTorch GPU + scientific Python + Jupyter/TensorBoard
- `VISION` — AI + OpenCV/YOLO/image tooling
- `UAV` — AI + MAVLink/MAVSDK helpers
- `SWARM-SIM` — AI + UAV + simulation/research Python packages
- `FULL` — all Python components

The installer uses `conda run -n uav-ai`, so it does not depend on PowerShell activation working correctly.

### 5. Verify

```powershell
conda run -n uav-ai python check_setup.py
```

For an activated environment:

```powershell
conda activate uav-ai
python check_setup.py
```

The checker validates Python, NumPy, PyTorch CUDA, NVIDIA GPU visibility, `nvcc` when present, and OpenCV.

## CUDA / PyTorch compatibility

The setup currently uses the official PyTorch CUDA 12.6 wheel because it works with a broad range of NVIDIA driver versions and is a good portable baseline for RTX systems. The NVIDIA driver and system CUDA Toolkit do not have to have the same version as PyTorch's bundled CUDA runtime.

Before changing the pinned PyTorch CUDA wheel for a newer GPU/driver generation, check the current official PyTorch Windows installation selector.

## Reproducibility

After a successful machine setup, save a machine-specific snapshot if desired:

```powershell
conda env export -n uav-ai > environment.yml
conda run -n uav-ai python -m pip freeze > requirements-lock.txt
```

Treat `requirements-lock.txt` and a full `environment.yml` export as **machine snapshots**, not universal files. They can contain platform-specific builds. The portable source of truth is the setup script plus the categorized requirements files.

## VS Code

Select this interpreter in VS Code:

```text
C:\Users\<USER>\miniconda3\envs\uav-ai\python.exe
```

Or use the repository's VS Code settings/extensions files.

## System-level UAV/simulation software

See the `cuda/` and `uav/` documentation for CUDA, PX4, MAVLink/MAVSDK, ROS 2, Gazebo, and simulation guidance. These components are intentionally separated from the Python bootstrap because their Windows support and version compatibility can change independently.

## Safety

For real aircraft, develop and validate in simulation/SITL first and follow applicable aviation, local, and safety requirements. This repository is for development, research, and simulation and does not implement autonomous weapon targeting or engagement logic.
