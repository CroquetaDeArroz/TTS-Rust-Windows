# Twitch TTS Bot — Windows

A **Text-to-Speech (TTS) bot for Twitch**, written in **Rust**, with a terminal-based configuration interface built using **Ratatui**.

Reads chat messages aloud through your system audio and lets the streamer control the volume via chat commands.


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
- Voice cloning via [Coqui XTTS-v2](https://github.com/coqui-ai/TTS) with included reference voices
- Fallback to gTTS if Piper fails
- Volume control via chat commands
- Configurable message length limit
- Terminal-based configuration UI (no config file editing needed)
- Native Windows audio via PowerShell (`System.Media.SoundPlayer`)

---

## Requirements

- **Windows 10 or 11** (64-bit)
- [Python 3.10 or newer](https://www.python.org/downloads/) — **must be added to PATH during installation**
- [Git for Windows](https://git-scm.com/download/win) (to clone the repo)
- Internet connection for the first run (to download models)

Rust is installed automatically by the installer script.

---

## Installation

### 1. Clone the repository

Open **PowerShell** and run:

```powershell
git clone https://github.com/CroquetaDeArroz/Bot-TTS-Rust.git
cd Bot-TTS-Rust
```

### 2. Allow script execution

PowerShell blocks scripts by default. Run this once:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### 3. Run the installer

```powershell
.\instalar.ps1
```

The script will automatically:
- Install **Rust** via rustup if not already present
- Install **gTTS** and **Coqui TTS** via pip
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
| TTS Engine | `piper` (offline) · `coqui` (local AI) · `gtts` (requires internet) |
| Piper Model | Path to the `.onnx` voice model file (set automatically by language) |
| Coqui Voice | Select model and reference voice with `←→` and `Enter` |
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

### Coqui XTTS-v2 reference voices

Three AI-generated reference voices are included in the `voices/` folder and pre-configured in the UI:

| Voice | File |
|---|---|
| Hannibal | `voices/hannibal.wav` |
| Enrique | `voices/enrique.wav` |
| Conchita | `voices/conchita.wav` |

Select **XTTS-v2** as the Coqui model and press `Enter` on the **Coqui Voice** field to switch between them.

> **Note:** XTTS-v2 downloads ~1.8 GB on first use and runs significantly faster with a GPU.

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

**Coqui TTS is slow**
XTTS-v2 is a large model. On CPU, synthesis can take several seconds per message. Use the `piper` engine for real-time performance, or use the `ES · css10 VITS` / `EN · ljspeech VITS` Coqui models which are lighter.

**Audio plays but volume control has no effect**
The `!volumen` command adjusts the internal multiplier sent to the audio API. If the system volume is very low, raise it directly in Windows volume mixer.

---

## Technologies

- [Rust](https://www.rust-lang.org/)
- [Ratatui](https://ratatui.rs/) — terminal UI
- [Piper TTS](https://github.com/rhasspy/piper) — offline TTS engine
- [Coqui TTS / XTTS-v2](https://github.com/coqui-ai/TTS) — AI voice cloning
- [gTTS](https://gtts.readthedocs.io/) — online TTS fallback
- PowerShell `System.Media.SoundPlayer` — Windows audio output
- Twitch IRC API

---

## Author

CroquetaDeArroz
