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
    if (Test-Command "nvidia-smi") {
        nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
        $driver = (nvidia-smi --query-gpu=driver_version --format=csv,noheader | Select-Object -First 1).Trim()
        try {
            $driverMajor = [int]($driver.Split('.')[0])
            if ($driverMajor -lt 580) {
                Write-Warning "NVIDIA driver $driver is older than the recommended R580+ branch for CUDA 13.x. Upgrade the NVIDIA driver before using CUDA 13.x runtime/tooling."
            }
        } catch { Write-Warning "Could not parse NVIDIA driver version: $driver" }
    } else { Write-Warning "nvidia-smi not found. Install/update the NVIDIA driver." }

    if (Test-Command "nvcc") {
        nvcc --version
        Write-Host "Note: nvcc version and the CUDA runtime bundled with PyTorch do not have to match."
    } else { Write-Warning "nvcc not found. Install CUDA Toolkit if you need CUDA C/C++ compilation." }

    if (Test-Command "git") { git --version }
    else { Write-Warning "Git not found." }
}

if (-not (Test-Command "conda")) { throw "Conda was not found. Install Miniconda or Miniforge, restart PowerShell, then rerun." }

$envExists = conda env list | Select-String "uav-ai"
if (-not $envExists) { conda create -y -n uav-ai python=3.11 }
conda run -n uav-ai python -m pip install --upgrade pip setuptools wheel

Write-Host "`nInstalling PyTorch GPU build..."
Write-Host "This setup uses the CUDA 12.6 PyTorch wheel because it is compatible with the current R560 driver and is a documented PyTorch Windows build."
Write-Host "If you upgrade to an R580+ NVIDIA driver, this can be changed to a CUDA 13.x wheel after verifying the current PyTorch selector."
conda run -n uav-ai pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

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
