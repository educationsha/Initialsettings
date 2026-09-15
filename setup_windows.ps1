param(
    [ValidateSet("AI","VISION","UAV","SWARM-SIM","FULL")]
    [string]$Profile = "FULL",
    [switch]$SkipSystemChecks
)

$ErrorActionPreference = "Stop"
Write-Host "=== UAV AI Windows Setup ===" -ForegroundColor Cyan
Write-Host "Profile: $Profile"

function Test-Command($name) { return $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }

if (-not $SkipSystemChecks) {
    Write-Host "`nChecking system tools..."
    if (Test-Command "nvidia-smi") { nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader }
    else { Write-Warning "nvidia-smi not found. Install/update the NVIDIA driver." }
    if (Test-Command "nvcc") { nvcc --version }
    else { Write-Warning "nvcc not found. Install CUDA Toolkit if you need CUDA C/C++ compilation." }
    if (Test-Command "git") { git --version }
    else { Write-Warning "Git not found." }
}

if (-not (Test-Command "conda")) { throw "Conda was not found. Install Miniconda/Anaconda, restart PowerShell, then rerun." }

$envExists = conda env list | Select-String "uav-ai"
if (-not $envExists) { conda create -y -n uav-ai python=3.11 }
conda run -n uav-ai python -m pip install --upgrade pip setuptools wheel

Write-Host "`nInstalling PyTorch..."
Write-Host "Check https://pytorch.org/get-started/locally/ if the CUDA wheel selector changes."
conda run -n uav-ai pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

conda run -n uav-ai pip install -r requirements-base.txt
switch ($Profile) {
    "AI" { conda run -n uav-ai pip install -r requirements-ai.txt }
    "VISION" { conda run -n uav-ai pip install -r requirements-ai.txt -r requirements-vision.txt }
    "UAV" { conda run -n uav-ai pip install -r requirements-ai.txt -r requirements-uav.txt }
    "SWARM-SIM" { conda run -n uav-ai pip install -r requirements-ai.txt -r requirements-uav.txt -r requirements-sim.txt }
    "FULL" { conda run -n uav-ai pip install -r requirements-ai.txt -r requirements-vision.txt -r requirements-uav.txt -r requirements-sim.txt }
}

Write-Host "`nSetup complete." -ForegroundColor Green
Write-Host "Activate: conda activate uav-ai"
Write-Host "Verify: python verify_gpu.py"
