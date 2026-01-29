# Ollama local Linux setup

This folder contains a systemd timer/service and an update script to keep the Ollama binary and selected models up to date on a Linux host.

## Project Structure

```

ollama/
├── README.md                          # This file
├── setup/                             # Setup and configuration files
│   ├── ollama_autoupdate_script       # Auto-update script for Ollama binary and models
│   ├── ollama_autoupdate.service      # systemd service unit
│   ├── ollama_autoupdate.timer        # systemd timer unit
│   ├── ollama_commands                # Useful CLI commands reference
│   ├── ollama_model_list              # List of models to keep updated
│   └── ollama_models_table.sh         # Script to generate model information table
├── test/                              # Test and example scripts
│   ├── main.py                        # Main entry point
│   ├── test_ollama_chat.py            # Chat API example
│   ├── test_ollama_streaming.py       # Streaming API example
│   └── test_ollama_translategemma.py  # TranslateGemma translation example
├── pyproject.toml                     # uv project configuration
└── .venv/                             # Virtual environment (created by uv)

```

## Prerequisites

- Linux host with systemd.
- Ollama installed and working (`ollama --version`).
- Root access for installing the script, unit files, and writing logs.

## Install the update script

1. Copy the script to a root-owned path on $PATH:
   - `/usr/local/sbin/ollama-autoupdate`

2. Ensure it is executable:
   - `chmod +x /usr/local/sbin/ollama-autoupdate`

## Configure the model list (optional)

Create `/etc/ollama/update-models.txt` with one model per line. You can start with the contents of `ollama_model_list`.

If the file is missing, the script only updates the Ollama binary.

## Install the systemd unit files

1. Copy the unit files:
   - `/etc/systemd/system/ollama-autoupdate.service`
   - `/etc/systemd/system/ollama-autoupdate.timer`

2. Reload systemd and enable the timer:
   - `systemctl daemon-reload`
   - `systemctl enable --now ollama-autoupdate.timer`

The timer runs daily at 11:30 with a randomized delay of up to 20 minutes (see `ollama_autoupdate.timer`).

## Run on demand

Start the service manually:

- `systemctl start ollama-autoupdate.service`

Check logs:

- `journalctl -u ollama-autoupdate.service -n 80 --no-pager`
- `tail -n 200 /var/log/ollama_update.log`

## Useful commands

See `ollama_commands` for copy/paste examples, including:

- Listing models: `ollama list`
- Showing a model: `ollama show gpt-oss:20b`
- API examples for `/api/generate` and `/api/chat`

## Test Scripts

The `test/` folder contains example scripts for testing Ollama API endpoints:

- **`test_ollama_chat.py`**: Demonstrates the `/api/chat` endpoint using the chat API with qwen2.5-coder model for code generation tasks.
- **`test_ollama_streaming.py`**: Shows streaming responses from the `/api/generate` endpoint, useful for long-running operations.
- **`test_ollama_translategemma.py`**: Uses the TranslateGemma model to translate text between languages with proper prompt formatting (English to Spanish example).

### Running test scripts

Ensure Ollama is running, then from the `test/` directory:

```bash
# Activate the virtual environment
source ../.venv/bin/activate

# Run a test script
python test_ollama_chat.py
python test_ollama_streaming.py
python test_ollama_translategemma.py
```

## Notes

- The script uses the official installer from <https://ollama.com/install.sh>.
- The update script holds a lock at `/var/lock/ollama_update.lock` to avoid concurrent runs.
- If `ollama.service` exists, it is restarted after a successful binary update.
