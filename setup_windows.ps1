param(
    [ValidateSet("AI","VISION","UAV","SWARM-SIM","FULL")]
    [string]$Profile = "FULL",
    [switch]$SkipSystemChecks
)

$ErrorActionPreference = "Stop"
Write-Host "=== Reusable UAV AI Windows Setup ===" -ForegroundColor Cyan
Write-Host "Profile: $Profile"

function Test-Command($name) { return $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }
function Run-Conda($args) { & conda run -n uav-ai $args }

if (-not $SkipSystemChecks) {
    Write-Host "`nChecking system prerequisites..."
    if (Test-Command "nvidia-smi") {
        nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
        $driver = (nvidia-smi --query-gpu=driver_version --format=csv,noheader | Select-Object -First 1).Trim()
        try {
            $driverMajor = [int]($driver.Split('.')[0])
            if ($driverMajor -lt 525) {
                Write-Warning "NVIDIA driver $driver is below the minimum range normally needed for current CUDA 12.x PyTorch builds. Update the driver."
            } elseif ($driverMajor -lt 580) {
                Write-Host "NVIDIA driver $driver detected. CUDA 12.x PyTorch build will be used for broad compatibility."
            } else {
                Write-Host "NVIDIA driver $driver detected. Newer CUDA builds may be available; verify the current PyTorch selector before changing versions."
            }
        } catch { Write-Warning "Could not parse NVIDIA driver version: $driver" }
    } else { Write-Warning "nvidia-smi not found. Install the NVIDIA driver before GPU setup." }

    if (Test-Command "nvcc") {
        nvcc --version
        Write-Host "Note: nvcc version and PyTorch's bundled CUDA runtime do not have to match."
    } else { Write-Warning "nvcc not found. Install CUDA Toolkit only if you need CUDA C/C++ compilation. Python GPU training can work without nvcc." }

    if (Test-Command "git") { git --version }
    else { Write-Warning "Git not found. Install Git for Windows to clone and maintain this repository." }
}

if (-not (Test-Command "conda")) { throw "Conda was not found. Install Miniconda or Miniforge, restart PowerShell, then rerun." }

$envExists = conda env list | Select-String "uav-ai"
if (-not $envExists) {
    Write-Host "Creating uav-ai with Python 3.11..."
    conda create -y -n uav-ai python=3.11
}

Write-Host "`nUpgrading packaging tools..."
Run-Conda python -m pip install --upgrade pip setuptools wheel

Write-Host "`nInstalling CUDA-enabled PyTorch..."
Write-Host "Using the CUDA 12.6 PyTorch wheel for compatibility with R525-R575 class NVIDIA drivers."
Write-Host "If the new PC has an R580+ driver, verify the current official PyTorch selector before switching to a CUDA 13.x wheel."
Run-Conda python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

Write-Host "`nInstalling base packages..."
Run-Conda python -m pip install -r requirements-base.txt

switch ($Profile) {
    "AI" { Run-Conda python -m pip install -r requirements-ai.txt }
    "VISION" { Run-Conda python -m pip install -r requirements-ai.txt; Run-Conda python -m pip install -r requirements-vision.txt }
    "UAV" { Run-Conda python -m pip install -r requirements-ai.txt; Run-Conda python -m pip install -r requirements-uav.txt }
    "SWARM-SIM" { Run-Conda python -m pip install -r requirements-ai.txt; Run-Conda python -m pip install -r requirements-uav.txt; Run-Conda python -m pip install -r requirements-sim.txt }
    "FULL" { Run-Conda python -m pip install -r requirements-ai.txt; Run-Conda python -m pip install -r requirements-vision.txt; Run-Conda python -m pip install -r requirements-uav.txt; Run-Conda python -m pip install -r requirements-sim.txt }
}

Write-Host "`nRunning verification..." -ForegroundColor Cyan
Run-Conda python check_setup.py

Write-Host "`nSetup complete." -ForegroundColor Green
Write-Host "For a new terminal, activate with: conda activate uav-ai"
Write-Host "Or run commands safely without activation: conda run -n uav-ai python <script.py>"
