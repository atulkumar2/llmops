# Ollama local Linux setup

This folder contains a systemd timer/service and an update script to keep the Ollama binary and selected models up to date on a Linux host.

**Part of a larger setup**: This Ollama installation runs as a systemd service on Linux and is accessed via [Open WebUI](../openwebui/README.md) running in Docker. Windows clients connect to the Open WebUI container, which communicates with the host-based Ollama service for GPU-accelerated inference.

## Architecture Overview

```text
Windows Client
   │
   │ HTTP
   ▼
Open WebUI (Docker on Linux)
   │
   ▼
Ollama (systemd service on Linux host)
   │
   ▼
NVIDIA GPU (CUDA on host)
```

See the [openwebui folder](../openwebui) for the Docker Compose setup and web interface configuration.

## Project Structure

```text
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

- Linux host with systemd
- Ollama installed and working (`ollama --version`)
- Root access for installing the script, unit files, and writing logs
- (Optional) NVIDIA GPU with CUDA for GPU-accelerated inference
- (Optional) [Open WebUI Docker setup](../openwebui) for web-based access

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

## Resources

### Related Documentation

- [Open WebUI Setup](../openwebui/README.md) - Docker-based web interface for Ollama (connects from Windows clients)

### Ollama Documentation and Downloads

- [Ollama Home](https://ollama.com/) - Official Ollama website
- [Ollama Library](https://ollama.com/library) - Browse available models
- [Ollama Documentation](https://docs.ollama.com/) - API and CLI documentation
- [Ollama GitHub](https://github.com/ollama/ollama) - Source code and issue tracker
- [Ollama Blog](https://ollama.com/blog) - Latest updates and announcements
- [Ollama Discord](https://discord.com/invite/ollama) - Community chat

### Models Used in This Project

- [Qwen2.5-Coder](https://ollama.com/library/qwen2.5-coder) - Code generation model (14B variant used)
- [Llama 3](https://ollama.com/library/llama3) - General-purpose LLM
- [TranslateGemma](https://ollama.com/library/translategemma) - Specialized translation model (55 languages)
- [Llava](https://ollama.com/library/llava) - Vision-language model
- [Deepseek R1](https://ollama.com/library/deepseek-r1) - Reasoning model
- [Mistral](https://ollama.com/library/mistral) - Efficient LLM
- [Nomic Embed Text](https://ollama.com/library/nomic-embed-text) - Text embedding model

### API Documentation

- [Ollama API Reference](https://docs.ollama.com/api) - Complete API endpoints
- [Generate Endpoint](https://docs.ollama.com/api/generate) - Text generation API
- [Chat Endpoint](https://docs.ollama.com/api/chat) - Chat completion API
- [Embedding Endpoint](https://docs.ollama.com/api/embed) - Text embedding API
