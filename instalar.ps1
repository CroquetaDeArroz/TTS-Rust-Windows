# ╔══════════════════════════════════════════════════════════════╗
# ║           Twitch TTS Bot — Instalador Windows               ║
# ║                  PowerShell 5.1 o superior                  ║
# ╚══════════════════════════════════════════════════════════════╝
#
# Ejecutar desde PowerShell como Administrador:
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#   .\instalar.ps1

$ErrorActionPreference = "Stop"

# ── Colores ───────────────────────────────────────────────────────────────────
function Ok($msg)   { Write-Host "  [OK] $msg"   -ForegroundColor Green  }
function Info($msg) { Write-Host "   >>  $msg"   -ForegroundColor Cyan   }
function Warn($msg) { Write-Host "  [!]  $msg"   -ForegroundColor Yellow }
function Err($msg)  { Write-Host "  [X]  $msg"   -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "  ████████╗████████╗███████╗    ██████╗  ██████╗ ████████╗" -ForegroundColor Magenta
Write-Host "     ██╔══╝╚══██╔══╝██╔════╝    ██╔══██╗██╔═══██╗╚══██╔══╝" -ForegroundColor Magenta
Write-Host "     ██║      ██║   ███████╗    ██████╔╝██║   ██║   ██║   " -ForegroundColor Magenta
Write-Host "     ██║      ██║   ╚════██║    ██╔══██╗██║   ██║   ██║   " -ForegroundColor Magenta
Write-Host "     ██║      ██║   ███████║    ██████╔╝╚██████╔╝   ██║   " -ForegroundColor Magenta
Write-Host "     ╚═╝      ╚═╝   ╚══════╝    ╚═════╝  ╚═════╝    ╚═╝   " -ForegroundColor Magenta
Write-Host ""
Write-Host "  Twitch TTS Bot — Instalador Windows v1.0" -ForegroundColor Magenta
Write-Host ""

$ProyectoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FilesDir    = $ProyectoDir
$PiperDir    = Join-Path $ProyectoDir "files\piper"

Info "Directorio del proyecto: $ProyectoDir"
Write-Host ""

# ── Paso 1: Rust ──────────────────────────────────────────────────────────────
Write-Host "── Paso 1/5  Rust ──" -ForegroundColor White

if (Get-Command cargo -ErrorAction SilentlyContinue) {
    $ver = cargo --version
    Ok "Rust ya instalado: $ver"
} else {
    Info "Descargando rustup-init.exe..."
    $rustupUrl  = "https://win.rustup.rs/x86_64"
    $rustupPath = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupPath
    Info "Instalando Rust (puede tardar unos minutos)..."
    & $rustupPath -y --default-toolchain stable | Out-Null
    
    # RECARGAR PATH (Lo nuevo va aquí exactamente)
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Ok "Rust instalado: $(cargo --version)"
}
Write-Host ""

# ── Paso 2: Python + gTTS + Coqui TTS ────────────────────────────────────────
Write-Host "── Paso 2/5  Python y motores TTS ──" -ForegroundColor White

if (Get-Command python -ErrorAction SilentlyContinue) {
    Ok "Python encontrado: $(python --version)"
} else {
    Warn "Python no encontrado. Descarga Python 3.10+ desde https://python.org"
    Warn "Asegúrate de marcar 'Add Python to PATH' durante la instalación."
    Err "Instala Python manualmente y vuelve a ejecutar este script."
}

Info "Instalando gTTS y Coqui TTS..."
pip install gtts TTS --quiet
Ok "gTTS y Coqui TTS instalados"
Write-Host ""

# ── Paso 3: Piper TTS ─────────────────────────────────────────────────────────
Write-Host "── Paso 3/5  Piper TTS ──" -ForegroundColor White

New-Item -ItemType Directory -Force -Path $PiperDir | Out-Null

$PiperExe = Join-Path $PiperDir "piper.exe"

if (Test-Path $PiperExe) {
    Ok "Piper ya descargado"
} else {
    Info "Descargando Piper TTS para Windows..."
    $PiperUrl = "https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_windows_amd64.zip"
    $PiperZip = Join-Path $env:TEMP "piper_windows.zip"

    Invoke-WebRequest -Uri $PiperUrl -OutFile $PiperZip
    Info "Extrayendo..."
    Expand-Archive -Path $PiperZip -DestinationPath $PiperDir -Force
    Remove-Item $PiperZip

    if (Test-Path $PiperExe) {
        Ok "Piper extraído correctamente"
    } else {
        Warn "No se encontró piper.exe en $PiperDir"
        Warn "Puede que la estructura del zip haya cambiado. Comprueba el contenido de $PiperDir"
    }
}
Write-Host ""

# ── Paso 4: Modelos de voz ────────────────────────────────────────────────────
Write-Host "── Paso 4/5  Modelos de voz ──" -ForegroundColor White

$ModeloEs   = Join-Path $PiperDir "es_ES-sharvard-medium.onnx"
$ModeloEsJ  = Join-Path $PiperDir "es_ES-sharvard-medium.onnx.json"
$ModeloEn   = Join-Path $PiperDir "en_US-lessac-medium.onnx"
$ModeloEnJ  = Join-Path $PiperDir "en_US-lessac-medium.onnx.json"
$BaseEs     = "https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_ES/sharvard/medium"
$BaseEn     = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium"

if ((Test-Path $ModeloEs) -and (Test-Path $ModeloEsJ)) {
    Ok "Modelo español ya descargado"
} else {
    Info "Descargando modelo español (es_ES-sharvard-medium)..."
    Invoke-WebRequest -Uri "$BaseEs/es_ES-sharvard-medium.onnx"      -OutFile $ModeloEs
    Invoke-WebRequest -Uri "$BaseEs/es_ES-sharvard-medium.onnx.json" -OutFile $ModeloEsJ
    Ok "Modelo español descargado"
}

if ((Test-Path $ModeloEn) -and (Test-Path $ModeloEnJ)) {
    Ok "Modelo inglés ya descargado"
} else {
    Info "Descargando modelo inglés (en_US-lessac-medium)..."
    Invoke-WebRequest -Uri "$BaseEn/en_US-lessac-medium.onnx"      -OutFile $ModeloEn
    Invoke-WebRequest -Uri "$BaseEn/en_US-lessac-medium.onnx.json" -OutFile $ModeloEnJ
    Ok "Modelo inglés descargado"
}
Write-Host ""

# ── Paso 5: Compilar el bot ───────────────────────────────────────────────────
Write-Host "── Paso 5/5  Compilando el bot ──" -ForegroundColor White

Info "Compilando para Windows (puede tardar unos minutos la primera vez)..."
Set-Location $FilesDir

$buildOutput = cargo build --release 2>&1
if ($LASTEXITCODE -eq 0) {
    Ok "Compilación exitosa"
} else {
    Write-Host $buildOutput
    Err "La compilación falló. Revisa los errores de arriba."
}

$BotExe      = Join-Path $FilesDir "target\release\bot.exe"
$ConfigExe   = Join-Path $FilesDir "target\release\config-ui.exe"

if ((Test-Path $BotExe) -and (Test-Path $ConfigExe)) {
    Ok "Binarios generados correctamente"
} else {
    Err "No se encontraron los ejecutables. Revisa la compilación."
}
Write-Host ""

# ── Variable de entorno PIPER_DIR ─────────────────────────────────────────────
Info "Configurando variable de entorno PIPER_DIR..."
[System.Environment]::SetEnvironmentVariable(
    "PIPER_DIR", $PiperDir,
    [System.EnvironmentVariableTarget]::User
)
Ok "PIPER_DIR=$PiperDir"
Write-Host ""

# ── Resumen final ─────────────────────────────────────────────────────────────
Write-Host "══════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  [OK]  Instalación completada"            -ForegroundColor Green
Write-Host "══════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Pasos siguientes:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Abre la configuración:" -ForegroundColor Cyan
Write-Host "     $ConfigExe" -ForegroundColor Yellow
Write-Host ""
Write-Host "  2. Elige idioma y rellena tus datos de Twitch" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Arranca el bot:" -ForegroundColor Cyan
Write-Host "     $BotExe" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Nota: el modelo Piper seleccionado se configura" -ForegroundColor DarkGray
Write-Host "  automáticamente según el idioma que elijas." -ForegroundColor DarkGray
Write-Host ""
