# LLMOps

A production-ready LLMOps setup for running **Ollama** (LLM inference engine) with **Open WebUI** (web interface) on Linux with NVIDIA GPU acceleration.

## Overview

This project provides a complete, automated setup for local LLM operations with the following design principles:

- **GPU stays on the host** (not inside Docker) for direct CUDA access
- **Ollama runs as a systemd service** for stability and automatic updates
- **Open WebUI runs in Docker** for easy management and updates
- **Automated maintenance** via systemd timers and Watchtower
- **Production-ready** with proper systemd integration and boot auto-start

## Architecture

```text
Windows/Linux Client
   │
   │ HTTP (Browser)
   ▼
Open WebUI (Docker container)
   │
   │ HTTP API
   ▼
Ollama (systemd service on Linux host)
   │
   │ CUDA
   ▼
NVIDIA GPU (on host)
```

**Key Components:**
- **Ollama Service**: Runs natively on the Linux host with direct GPU access via CUDA
- **Open WebUI**: Web-based chat interface running in Docker, connects to host Ollama service
- **Auto-updates**: Systemd timer for Ollama binary and models, Watchtower for Docker containers
- **Test Scripts**: Python examples for testing Ollama API endpoints

## Project Structure

```text
llmops/
├── README.md                    # This file - project overview
├── pyproject.toml               # Python project configuration (uv)
├── uv.lock                      # Dependency lock file
├── .python-version              # Python version specification
│
├── ollama/                      # Ollama setup and automation
│   ├── README.md                # Detailed Ollama setup instructions
│   ├── setup/                   # Systemd units and update scripts
│   │   ├── ollama_autoupdate_script      # Auto-update script
│   │   ├── ollama_autoupdate.service     # Systemd service
│   │   ├── ollama_autoupdate.timer       # Systemd timer (daily updates)
│   │   ├── ollama_commands               # CLI reference
│   │   ├── ollama_model_list             # Models to auto-update
│   │   └── ollama_models_table.sh        # Model info generator
│   └── test/                    # Test and example scripts
│       ├── main.py              # Main entry point
│       ├── test_ollama_chat.py           # Chat API example
│       ├── test_ollama_streaming.py      # Streaming API example
│       └── test_ollama_translategemma.py # Translation example
│
└── openwebui/                   # Open WebUI Docker setup
    ├── README.md                # Detailed Open WebUI setup instructions
    ├── docker-compose.yaml      # Docker Compose configuration
    └── .env                     # Environment configuration (not in repo)
```

## Prerequisites

### Hardware
- Linux host (Ubuntu 20.04+ or similar)
- NVIDIA GPU with CUDA support
- Sufficient disk space for models (50GB+ recommended)

### Software
- Linux with systemd
- Docker and Docker Compose plugin
- NVIDIA Driver and CUDA toolkit
- Python 3.13+ (for test scripts)
- [uv](https://github.com/astral-sh/uv) package manager (optional, for test scripts)

## Quick Start

### 1. Install Ollama

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Verify installation
ollama --version

# Pull a model
ollama pull llama3.1
```

See [ollama/README.md](ollama/README.md) for:
- Systemd auto-update setup (daily updates for Ollama binary and models)
- Model management
- API usage examples

### 2. Set Up Open WebUI

```bash
# Create installation directory
sudo mkdir -p /opt/openwebui
cd /opt/openwebui

# Copy docker-compose.yaml from this repo
sudo cp openwebui/docker-compose.yaml .

# Generate secret key
openssl rand -hex 32 | sudo tee .env
sudo chmod 600 .env

# Start services
sudo docker compose up -d
```

Access Open WebUI at `http://localhost:3000`

See [openwebui/README.md](openwebui/README.md) for:
- Detailed configuration
- Systemd auto-start setup
- Watchtower auto-updates
- Troubleshooting

## Features

### Ollama Features
- ✅ Native GPU acceleration (CUDA)
- ✅ Automated daily updates (binary + models)
- ✅ Systemd service integration
- ✅ Lock-based update safety
- ✅ Comprehensive logging
- ✅ Multiple model support

### Open WebUI Features
- ✅ Modern web-based chat interface
- ✅ Multi-model support
- ✅ Chat history and management
- ✅ Auto-updates via Watchtower
- ✅ Systemd auto-start on boot
- ✅ Secure session management

### Test Scripts
- ✅ Chat API examples (`test_ollama_chat.py`)
- ✅ Streaming API examples (`test_ollama_streaming.py`)
- ✅ Translation examples (`test_ollama_translategemma.py`)
- ✅ Code generation examples using qwen2.5-coder

## Models Included

The setup supports various models for different use cases:

- **[Qwen2.5-Coder](https://ollama.com/library/qwen2.5-coder)** (14B) - Code generation and assistance
- **[Llama 3](https://ollama.com/library/llama3)** - General-purpose LLM
- **[TranslateGemma](https://ollama.com/library/translategemma)** - Translation (55 languages)
- **[Llava](https://ollama.com/library/llava)** - Vision-language model
- **[Deepseek R1](https://ollama.com/library/deepseek-r1)** - Advanced reasoning
- **[Mistral](https://ollama.com/library/mistral)** - Efficient LLM
- **[Nomic Embed Text](https://ollama.com/library/nomic-embed-text)** - Text embeddings

## Testing

Run the included test scripts to verify your setup:

```bash
# Navigate to the test directory
cd ollama/test

# Create virtual environment (using uv)
uv sync

# Run tests
uv run python test_ollama_chat.py
uv run python test_ollama_streaming.py
uv run python test_ollama_translategemma.py
```

## Maintenance

### Ollama Updates
- **Automatic**: Daily via systemd timer (configured in `ollama/setup/`)
- **Manual**: `sudo systemctl start ollama-autoupdate.service`

### Open WebUI Updates
- **Automatic**: Every 24 hours via Watchtower
- **Manual**: `cd /opt/openwebui && sudo docker compose pull && sudo docker compose up -d`

### Logs
```bash
# Ollama service logs
journalctl -u ollama.service -n 50

# Ollama auto-update logs
journalctl -u ollama-autoupdate.service -n 50
tail -n 100 /var/log/ollama_update.log

# Open WebUI logs
docker logs -f openwebui

# Watchtower logs
docker logs watchtower
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Open WebUI can't connect to Ollama | Ensure Ollama is bound to `0.0.0.0:11434` (see [openwebui/README.md](openwebui/README.md)) |
| No GPU acceleration | Verify `nvidia-smi` works and CUDA is properly installed |
| Models not updating | Check `/var/log/ollama_update.log` and systemd timer status |
| Session resets in UI | Don't change `WEBUI_SECRET_KEY` in `.env` |

See component-specific READMEs for detailed troubleshooting:
- [ollama/README.md](ollama/README.md) - Ollama issues
- [openwebui/README.md](openwebui/README.md) - Open WebUI issues

## Resources

### Documentation
- [Ollama Documentation](https://docs.ollama.com/)
- [Ollama API Reference](https://docs.ollama.com/api)
- [Open WebUI Documentation](https://docs.openwebui.com/)
- [Ollama Model Library](https://ollama.com/library)

### Project Links
- [Ollama GitHub](https://github.com/ollama/ollama)
- [Open WebUI GitHub](https://github.com/open-webui/open-webui)
- [uv Package Manager](https://github.com/astral-sh/uv)

### Community
- [Ollama Discord](https://discord.com/invite/ollama)
- [Ollama Blog](https://ollama.com/blog)

## Design Rationale

This setup follows these principles:

1. **GPU Outside Docker**: Running Ollama natively on the host avoids Docker CUDA complexity and provides better performance
2. **Systemd Integration**: Proper service management ensures stability and automatic recovery
3. **Separation of Concerns**: UI layer (Docker) is separate from inference layer (host service)
4. **Automated Maintenance**: Reduces manual intervention with safe, tested automation
5. **Production Ready**: Designed for long-running, reliable operation

## License

This project configuration is provided as-is for setting up and managing Ollama and Open WebUI. Please refer to the respective projects for their licenses:
- Ollama: MIT License
- Open WebUI: MIT License

## Contributing

This is a personal LLMOps setup. Feel free to fork and adapt for your needs. Suggestions and improvements are welcome via issues or pull requests.

## Status

✅ Production-ready for single-host deployment  
✅ CUDA GPU acceleration verified  
✅ Automated updates working  
✅ Boot auto-start configured  
✅ Test scripts validated  
