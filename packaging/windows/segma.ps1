# Lanceur SEGMA (Windows) : configure l'environnement au 1er lancement,
# démarre le backend FastAPI puis l'application Flutter.
param([switch]$HideConsole)   # utilisé par les raccourcis : masque la console une fois prêt
$ErrorActionPreference = 'Stop'

trap {
  Write-Host "Erreur : $_" -ForegroundColor Red
  Read-Host "Appuyez sur Entrée pour fermer"
  exit 1
}

$Root     = Split-Path -Parent $MyInvocation.MyCommand.Path
$DataDir  = if ($env:SEGMA_HOME) { $env:SEGMA_HOME } else { Join-Path $env:LOCALAPPDATA 'segma' }
$Venv     = Join-Path $DataDir 'venv'
$VenvPy   = Join-Path $Venv 'Scripts\python.exe'
$Port     = if ($env:SEGMA_PORT) { $env:SEGMA_PORT } else { '8000' }
$AppExe   = Join-Path $Root 'app\segma.exe'
$Req      = Join-Path $Root 'backend\requirements.txt'
$HashFile = Join-Path $DataDir '.setup-hash'
$EnvFile  = Join-Path $DataDir '.env'
$Sam3Spec = if ($null -ne $env:SAM3_SPEC) { $env:SAM3_SPEC } else { '' }
New-Item -ItemType Directory -Force $DataDir | Out-Null

function Run($exe, [string[]]$arguments) {
  & $exe @arguments
  if ($LASTEXITCODE -ne 0) { throw "Échec : $exe $($arguments -join ' ')" }
}

function Find-Python {
  $candidates = @(
    @{ Exe = 'py';     Args = @('-3.12') },
    @{ Exe = 'py';     Args = @('-3.11') },
    @{ Exe = 'py';     Args = @('-3.10') },
    @{ Exe = 'python'; Args = @() }
  )
  foreach ($c in $candidates) {
    if (-not (Get-Command $c.Exe -ErrorAction SilentlyContinue)) { continue }
    $out = & $c.Exe @($c.Args) -c "import sys; print(int(sys.version_info >= (3,10)))" 2>$null
    if ($LASTEXITCODE -eq 0 -and "$out".Trim() -eq '1') { return $c }
  }
  return $null
}

function Setup {
  $py = Find-Python
  if (-not $py) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
      Write-Host "Python >= 3.10 introuvable : installation de Python 3.12 via winget..."
      winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements
      throw "Python vient d'être installé : relancez SEGMA pour appliquer les variables d'environnement."
    }
    throw "Python >= 3.10 introuvable. Installez Python 3.12 (https://www.python.org/downloads/) puis relancez SEGMA."
  }

  # Vérification de Git (requis pour installer les dépendances git+https)
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
      Write-Host "Git introuvable (requis pour certaines dépendances) : installation via winget..."
      winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
      Write-Host "Git installé. Si l'installation échoue, relancez SEGMA."
    } else {
      Write-Host "!! Git n'est pas détecté. Si l'installation échoue, installez Git (https://git-scm.com/download/win)." -ForegroundColor Yellow
    }
  }

  Write-Host "==> Première configuration (quelques minutes, ne fermez pas cette fenêtre)..."
  Run $py.Exe (@($py.Args) + @('-m', 'venv', $Venv))
  Run $VenvPy @('-m', 'pip', 'install', '--upgrade', 'pip')

  $index = $env:TORCH_INDEX_URL
  if (-not $index) {
    if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
      $index = 'https://download.pytorch.org/whl/cu126'
    } else {
      $index = 'https://download.pytorch.org/whl/cpu'
      Write-Host "!! Aucun GPU NVIDIA détecté : la segmentation sera lente (CPU)."
    }
  }

  Write-Host "==> Installation de PyTorch et torchvision..."
  Run $VenvPy @('-m', 'pip', 'install', 'torch==2.7.0', 'torchvision==0.22.0', '--index-url', $index)

  Write-Host "==> Installation des dépendances SEGMA..."
  Run $VenvPy @('-m', 'pip', 'install', '-r', $Req, '--extra-index-url', $index)

  if ($Sam3Spec) {
    Write-Host "==> Installation de la spécification SAM 3 personnalisée ($Sam3Spec)..."
    Run $VenvPy @('-m', 'pip', 'install', $Sam3Spec)
  }

  (Get-FileHash $Req -Algorithm SHA256).Hash | Set-Content $HashFile
}

# (Ré)installe si le venv est absent ou si requirements.txt a changé
$currentHash = (Get-FileHash $Req -Algorithm SHA256).Hash
$savedHash   = if (Test-Path $HashFile) { (Get-Content $HashFile -Raw).Trim() } else { '' }
if (-not (Test-Path $VenvPy) -or $savedHash -ne $currentHash) {
  if (Test-Path $Venv) { Remove-Item -Recurse -Force $Venv }
  Setup
}

if (-not (Test-Path $EnvFile)) { Copy-Item (Join-Path $Root '.env.example') $EnvFile }
Get-Content $EnvFile | ForEach-Object {
  if ($_ -match '^\s*([^#=\s]+)\s*=\s*(.*?)\s*$') {
    [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2].Trim('"'), 'Process')
  }
}

Write-Host "==> Démarrage du backend sur 127.0.0.1:$Port"
$backend = Start-Process -FilePath $VenvPy `
  -ArgumentList @('-m', 'uvicorn', 'main:app', '--app-dir', "`"$(Join-Path $Root 'backend')`"",
                  '--host', '127.0.0.1', '--port', $Port) `
  -WorkingDirectory $DataDir `
  -RedirectStandardOutput (Join-Path $DataDir 'backend.log') `
  -RedirectStandardError  (Join-Path $DataDir 'backend.err.log') `
  -WindowStyle Hidden -PassThru

try {
  $ready = $false
  for ($i = 0; $i -lt 180 -and -not $ready; $i++) {
    if ($backend.HasExited) { throw "Le backend s'est arrêté inopinément, voir $DataDir\backend.err.log" }
    try {
      Invoke-WebRequest "http://127.0.0.1:$Port/docs" -UseBasicParsing -TimeoutSec 1 | Out-Null
      $ready = $true
    } catch { Start-Sleep -Seconds 1 }
  }
  if (-not $ready) { throw "Le backend ne répond pas sur le port $Port (délai dépassé), voir $DataDir\backend.err.log" }

  if ($HideConsole) {
    Add-Type -Namespace Win32 -Name Native -MemberDefinition @'
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@
    [Win32.Native]::ShowWindow([Win32.Native]::GetConsoleWindow(), 0) | Out-Null
  }

  Start-Process -FilePath $AppExe -Wait
}
finally {
  if ($backend -and -not $backend.HasExited) { taskkill /PID $backend.Id /T /F | Out-Null }
}
