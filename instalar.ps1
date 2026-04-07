$ErrorActionPreference = "Stop"

function Ok($msg)   { Write-Host "  [OK] $msg"   -ForegroundColor Green  }
function Info($msg) { Write-Host "   >>  $msg"   -ForegroundColor Cyan   }
function Warn($msg) { Write-Host "  [!]  $msg"   -ForegroundColor Yellow }
function Err($msg)  { Write-Host "  [X]  $msg"   -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "  Twitch TTS Bot — Instalador completo (Piper + gTTS)" -ForegroundColor Magenta
Write-Host ""

$ProyectoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$FilesDir    = $ProyectoDir
$PiperDir    = Join-Path $ProyectoDir "files\piper"

Info "Directorio del proyecto: $ProyectoDir"
Write-Host ""

function Reload-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Download($url, $dest) {
    Info "Descargando: $(Split-Path $url -Leaf)"
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
    $ProgressPreference = "Continue"
}

Write-Host "── Paso 1/5  Python ──" -ForegroundColor White

Reload-Path

if (Get-Command python -ErrorAction SilentlyContinue) {
    Ok "Python ya instalado: $(python --version 2>&1)"
} else {
    Info "Python no encontrado. Descargando Python 3.12 (64-bit)..."
    $PyInstPath = "$env:TEMP\python-installer.exe"
    Download "https://www.python.org/ftp/python/3.12.4/python-3.12.4-amd64.exe" $PyInstPath

    Info "Instalando Python 3.12..."
    $proc = Start-Process -FilePath $PyInstPath `
        -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_test=0" `
        -Wait -PassThru
    Remove-Item $PyInstPath -ErrorAction SilentlyContinue
    if ($proc.ExitCode -ne 0) {
        Err "La instalacion de Python fallo (codigo $($proc.ExitCode))."
    }

    Reload-Path

    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Err "Python instalado pero no encontrado en PATH. Reinicia PowerShell y vuelve a ejecutar."
    }
    Ok "Python instalado: $(python --version 2>&1)"
}
Write-Host ""

Write-Host "── Paso 2/5  Rust ──" -ForegroundColor White

Reload-Path

if (Get-Command cargo -ErrorAction SilentlyContinue) {
    Ok "Rust ya instalado: $(cargo --version)"
} else {
    Info "Rust no encontrado. Descargando rustup-init.exe..."
    $RustupPath = "$env:TEMP\rustup-init.exe"
    Download "https://win.rustup.rs/x86_64" $RustupPath

    Info "Instalando Rust stable (puede tardar unos minutos)..."
    $proc = Start-Process -FilePath $RustupPath `
        -ArgumentList "-y --default-toolchain stable" `
        -Wait -PassThru
    Remove-Item $RustupPath -ErrorAction SilentlyContinue
    if ($proc.ExitCode -ne 0) {
        Err "La instalacion de Rust fallo (codigo $($proc.ExitCode))."
    }

    Reload-Path

    $CargoBin = "$env:USERPROFILE\.cargo\bin"
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        if (Test-Path "$CargoBin\cargo.exe") {
            $env:Path = "$CargoBin;$env:Path"
        } else {
            Err "Cargo no encontrado tras instalar Rust. Reinicia PowerShell y vuelve a ejecutar."
        }
    }
    Ok "Rust instalado: $(cargo --version)"
}
Write-Host ""

Write-Host "── Paso 3/5  gTTS (fallback online) ──" -ForegroundColor White

Info "Actualizando pip e instalando gTTS..."
python -m pip install --upgrade pip --quiet
python -m pip install gtts --quiet
Ok "gTTS instalado"
Write-Host ""

Write-Host "── Paso 4/5  Piper TTS y modelos de voz ──" -ForegroundColor White

New-Item -ItemType Directory -Force -Path $PiperDir | Out-Null
$PiperExe = Join-Path $PiperDir "piper.exe"

if (Test-Path $PiperExe) {
    Ok "Piper ya descargado"
} else {
    Info "Descargando Piper TTS para Windows (x64)..."
    $PiperZip = "$env:TEMP\piper_windows.zip"
    Download "https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_windows_amd64.zip" $PiperZip

    Info "Extrayendo Piper..."
    Expand-Archive -Path $PiperZip -DestinationPath $PiperDir -Force
    Remove-Item $PiperZip -ErrorAction SilentlyContinue

    if (-not (Test-Path $PiperExe)) {
        $found = Get-ChildItem -Path $PiperDir -Recurse -Filter "piper.exe" | Select-Object -First 1
        if ($found) {
            Get-ChildItem -Path $found.DirectoryName | Move-Item -Destination $PiperDir -Force
            Remove-Item $found.DirectoryName -ErrorAction SilentlyContinue
        }
    }

    if (Test-Path $PiperExe) { Ok "Piper extraido correctamente" }
    else { Warn "piper.exe no encontrado en $PiperDir — revisa el contenido manualmente." }
}

$ModeloEs  = Join-Path $PiperDir "es_ES-sharvard-medium.onnx"
$ModeloEsJ = Join-Path $PiperDir "es_ES-sharvard-medium.onnx.json"
$ModeloEn  = Join-Path $PiperDir "en_US-lessac-medium.onnx"
$ModeloEnJ = Join-Path $PiperDir "en_US-lessac-medium.onnx.json"
$BaseEs    = "https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_ES/sharvard/medium"
$BaseEn    = "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium"

if ((Test-Path $ModeloEs) -and (Test-Path $ModeloEsJ)) {
    Ok "Modelo espanol ya descargado"
} else {
    Info "Descargando modelo espanol es_ES-sharvard-medium (~60 MB)..."
    Download "$BaseEs/es_ES-sharvard-medium.onnx"      $ModeloEs
    Download "$BaseEs/es_ES-sharvard-medium.onnx.json" $ModeloEsJ
    Ok "Modelo espanol descargado"
}

if ((Test-Path $ModeloEn) -and (Test-Path $ModeloEnJ)) {
    Ok "Modelo ingles ya descargado"
} else {
    Info "Descargando modelo ingles en_US-lessac-medium (~60 MB)..."
    Download "$BaseEn/en_US-lessac-medium.onnx"      $ModeloEn
    Download "$BaseEn/en_US-lessac-medium.onnx.json" $ModeloEnJ
    Ok "Modelo ingles descargado"
}
Write-Host ""

Write-Host "── Paso 5/5  Compilando el bot ──" -ForegroundColor White

Info "Compilando para Windows (puede tardar varios minutos la primera vez)..."
Set-Location $FilesDir

cargo build --release
if ($LASTEXITCODE -ne 0) {
    Err "La compilacion fallo. Revisa los errores de arriba."
}

$BotExe    = Join-Path $FilesDir "target\release\bot.exe"
$ConfigExe = Join-Path $FilesDir "target\release\config-ui.exe"

if ((Test-Path $BotExe) -and (Test-Path $ConfigExe)) {
    Ok "Binarios generados correctamente"
} else {
    Err "No se encontraron los ejecutables. Revisa la compilacion."
}
Write-Host ""

Info "Configurando variable de entorno PIPER_DIR..."
[System.Environment]::SetEnvironmentVariable(
    "PIPER_DIR", $PiperDir,
    [System.EnvironmentVariableTarget]::User
)
Ok "PIPER_DIR=$PiperDir"
Write-Host ""

Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  [OK]  Instalacion completada"                    -ForegroundColor Green
Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Motores disponibles:" -ForegroundColor White
Write-Host "    piper  — offline, recomendado (ya configurado)" -ForegroundColor Green
Write-Host "    gtts   — fallback online (requiere internet)"   -ForegroundColor Yellow
Write-Host "    coqui  — NO instalado en esta version"         -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Pasos siguientes:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Abre la configuracion:" -ForegroundColor Cyan
Write-Host "     $ConfigExe" -ForegroundColor Yellow
Write-Host ""
Write-Host "  2. Elige idioma, rellena tus datos de Twitch" -ForegroundColor Cyan
Write-Host "     y selecciona 'piper' como motor TTS." -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Arranca el bot:" -ForegroundColor Cyan
Write-Host "     $BotExe" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Nota: si acabas de instalar Python o Rust por primera" -ForegroundColor DarkGray
Write-Host "  vez y algo falla, cierra y vuelve a abrir PowerShell." -ForegroundColor DarkGray
Write-Host ""
