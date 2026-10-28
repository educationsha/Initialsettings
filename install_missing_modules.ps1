# Install missing UAV AI modules into the dedicated Conda environment.
# This script deliberately calls the environment's Python directly, avoiding
# the previous "conda: error: unrecognized arguments: -m" issue.
# Project location: C:\UAV-AI\Initialsettings
# Environment:      %USERPROFILE%\miniconda3\envs\uav-ai

$ErrorActionPreference = "Stop"

$PythonExe = Join-Path $env:USERPROFILE "miniconda3\envs\uav-ai\python.exe"

Write-Host "=== UAV AI Missing Modules Installer ===" -ForegroundColor Cyan
Write-Host "Target Python: $PythonExe"

if (-not (Test-Path -LiteralPath $PythonExe)) {
    throw @"
The uav-ai environment Python was not found:
  $PythonExe

Create/check the environment first, then run this installer again.
"@
}

# Ensure the script is installing into Python 3.11, not the Conda base Python.
$pythonVersion = & $PythonExe -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')"
if ($LASTEXITCODE -ne 0) {
    throw "Could not query the target Python version."
}
Write-Host "Python version: $pythonVersion"

if (-not $pythonVersion.StartsWith("3.11.")) {
    throw "Expected Python 3.11 in the uav-ai environment, but found $pythonVersion. Stopping to avoid installing into the wrong environment."
}

function Invoke-PythonChecked {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$PythonArgs,

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    Write-Host "`n>>> $Description" -ForegroundColor Yellow
    & $PythonExe @PythonArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Failed: $Description (exit code $LASTEXITCODE)"
    }
}

# Update packaging tools in the target environment.
Invoke-PythonChecked -PythonArgs @("-m", "pip", "install", "--upgrade", "pip", "setuptools", "wheel") `
    -Description "Upgrade pip, setuptools, and wheel"

# Install CUDA-enabled PyTorch wheels. The NVIDIA driver is installed separately;
# a local CUDA Toolkit/nvcc is not required for normal use of these prebuilt wheels.
Invoke-PythonChecked -PythonArgs @("-m", "pip", "install", "torch", "torchvision", "torchaudio", "--index-url", "https://download.pytorch.org/whl/cu126") `
    -Description "Install CUDA-enabled PyTorch (CUDA 12.6 wheels)"

# Install the modules reported missing by check_setup.py.
Invoke-PythonChecked -PythonArgs @("-m", "pip", "install", "numpy", "opencv-python", "ultralytics") `
    -Description "Install NumPy, OpenCV, and Ultralytics"

# Verify imports and CUDA visibility using a temporary Python file.
# This avoids PowerShell quoting problems with python -c.
Write-Host "`n=== Verification ===" -ForegroundColor Cyan

$verifyScript = Join-Path $env:TEMP "verify_uav_ai_modules.py"
$verifyCode = @'
import sys
print("Python:", sys.version.split()[0])
print("Executable:", sys.executable)

import numpy
print("NumPy:", numpy.__version__)

import cv2
print("OpenCV:", cv2.__version__)

import ultralytics
print("Ultralytics:", ultralytics.__version__)

import torch
print("PyTorch:", torch.__version__)
print("PyTorch CUDA build:", torch.version.cuda)
print("CUDA available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name(0))
'@

try {
    Set-Content -LiteralPath $verifyScript -Value $verifyCode -Encoding UTF8
    & $PythonExe $verifyScript
    if ($LASTEXITCODE -ne 0) {
        throw "Installation ran, but verification failed. Review the error above."
    }
}
finally {
    Remove-Item -LiteralPath $verifyScript -Force -ErrorAction SilentlyContinue
}

Write-Host "`nModule installation and verification completed." -ForegroundColor Green
Write-Host "Run the setup checker using this environment's Python:"
Write-Host '& "$env:USERPROFILE\miniconda3\envs\uav-ai\python.exe" .\check_setup.py'
