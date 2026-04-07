# Twitch TTS Bot — Windows

A **Text-to-Speech (TTS) bot for Twitch**, written in **Rust**, with a terminal-based configuration interface built using **Ratatui**.

Reads chat messages aloud through your system audio and lets the streamer control the volume via chat commands.

![preview](preview.png)

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Bot](#running-the-bot)
- [Chat Commands](#chat-commands)
- [Technologies](#technologies)

---

## Features

- Text-to-Speech playback of Twitch chat messages
- Bilingual support — **Spanish** and **English** (chosen on first launch)
- Offline voices powered by [Piper TTS](https://github.com/rhasspy/piper) (no API key needed)
- Fallback to gTTS if Piper fails
- Volume control via chat commands
- Configurable message length limit
- Terminal-based configuration UI (no config file editing needed)
- Native Windows audio via PowerShell (`System.Media.SoundPlayer`)

---

## Requirements

- **Windows 10 or 11** (64-bit)
- Internet connection for the first run (to download models)

Everything else — Python, Rust, Piper, and gTTS — is installed automatically by the installer script.

---

## Installation

### 1. Clone the repository

Open **PowerShell** and run:

```powershell
git clone https://github.com/CroquetaDeArroz/Bot-TTS-Rust.git
cd Bot-TTS-Rust
```

> If you don't have Git, download it from [git-scm.com](https://git-scm.com/download/win) or just download the repo as a ZIP from GitHub.

### 2. Allow script execution

PowerShell blocks scripts by default. Run this once:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### 3. Run the installer

```powershell
.\instalar_sin_coqui.ps1
```

The script will automatically:
- Install **Python 3.12** (only if not already present, no admin required)
- Install **Rust** via rustup (only if not already present)
- Install **gTTS** via pip
- Download the **Piper TTS** Windows binary
- Download both voice models — Spanish (`es_ES-sharvard-medium`) and English (`en_US-lessac-medium`)
- Compile the bot and config UI
- Set the `PIPER_DIR` environment variable

> ⚠️ The first compilation takes a few minutes. Subsequent builds are fast.

### 4. Get a Twitch token

1. Go to: https://twitchtokengenerator.com/
2. Log in with your **bot account**
3. Copy the `ACCESS TOKEN`

### 5. Configure the bot

```powershell
.\target\release\config-ui.exe
```

On first launch you will be asked to choose a language. After that, fill in your Twitch credentials and press `Ctrl+S` to save.

---

## Configuration

Navigate with `↑↓` or `j`/`k`, adjust values with `←→`, edit text fields with `Enter`. Save with `Ctrl+S`.

| Field | Description |
|---|---|
| Username | Your Twitch bot's username |
| Token OAuth | `oauth:xxxxxxxx` — get it at twitchtokengenerator.com |
| Channel | Channel to join, with `#` (e.g. `#mychannel`) |
| Volume | Playback volume, 0%–200% |
| TTS Engine | `piper` (offline, recommended) · `gtts` (requires internet) |
| Piper Model | Path to the `.onnx` voice model file (set automatically by language) |
| Max Length | Max characters per message to read aloud |
| Announce user | Whether to read `"username says ..."` before each message |

The configuration is saved to `%APPDATA%\twitch-tts\config.json` and persists between runs.

---

## Running the Bot

```powershell
.\target\release\bot.exe
```

The bot connects to Twitch IRC and starts reading chat messages aloud through your default Windows audio device.

To keep it running in the background, right-click the executable and create a shortcut, or use Windows Task Scheduler.

---

## Voice Models

The installer downloads two Piper models automatically:

| Model | Language | Size |
|---|---|---|
| `es_ES-sharvard-medium` | Spanish | ~60 MB |
| `en_US-lessac-medium` | English | ~60 MB |

The active model is selected automatically based on the language you choose on first launch. You can change it later in the config UI under **Piper Model**.

---

## Chat Commands

| Command | Effect |
|---|---|
| `!volumen 80` | Sets volume to 80% |
| `!volumen +10` | Increases volume by 10% |
| `!volumen -10` | Decreases volume by 10% |

> Only the streamer (the configured username) can use these commands.

---

## Troubleshooting

**The bot says "No language configured"**
Run `config-ui.exe` first and complete the setup.

**Piper produces no audio**
Check that `PIPER_DIR` points to the folder containing `piper.exe`. The installer sets this automatically, but if you moved the folder you can update it manually:
```powershell
[System.Environment]::SetEnvironmentVariable("PIPER_DIR", "C:\path\to\files\piper", "User")
```
Then restart PowerShell.

**PowerShell blocks the script**
Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` as shown in the installation steps.

**Audio plays but volume control has no effect**
The `!volumen` command adjusts the internal multiplier sent to the audio API. If the system volume is very low, raise it directly in Windows volume mixer.

**Python or Rust not found after installation**
Close PowerShell completely and reopen it. The PATH changes made by the installer take effect in new sessions.

---

## Technologies

- [Rust](https://www.rust-lang.org/)
- [Ratatui](https://ratatui.rs/) — terminal UI
- [Piper TTS](https://github.com/rhasspy/piper) — offline TTS engine
- [gTTS](https://gtts.readthedocs.io/) — online TTS fallback
- PowerShell `System.Media.SoundPlayer` — Windows audio output
- Twitch IRC API

---

## Author

CroquetaDeArroz
