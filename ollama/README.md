# Ollama local Linux setup

This folder contains a systemd timer/service and an update script to keep the Ollama binary and selected models up to date on a Linux host.

## Files

- `ollama_autoupdate_script`: Updates the Ollama binary and optionally pulls models listed in `/etc/ollama/update-models.txt`. Logs to `/var/log/ollama_update.log`.
- `ollama_autoupdate.service`: systemd oneshot service that runs the update script.
- `ollama_autoupdate.timer`: systemd timer that runs the service daily.
- `ollama_commands`: handy commands for verification and API calls.
- `ollama_model_list`: sample list of models (one per line).

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

## Notes

- The script uses the official installer from <https://ollama.com/install.sh>.
- The update script holds a lock at `/var/lock/ollama_update.lock` to avoid concurrent runs.
- If `ollama.service` exists, it is restarted after a successful binary update.
