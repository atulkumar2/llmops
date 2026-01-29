# Open WebUI (Docker) + Host Ollama (CUDA)

This setup runs **Open WebUI** in Docker while **Ollama runs as a systemd service on the host**, using **NVIDIA CUDA directly**.
Docker is used only for the UI layer — no model runtime inside containers.

Auto-updates are handled via **Watchtower (24-hour checks)**, and the stack auto-starts on boot using **systemd**.

---

## Architecture

```sh

Linux Host
   │
   ├── Ollama (systemd service, host)
   │      │
   │      ▼
   │   NVIDIA GPU (CUDA)
   │
   ├── Docker
Browser
   │
   ▼
Open WebUI (Docker container)
   │  HTTP
   ▼
Ollama (systemd service, host)
   │
   ▼
NVIDIA GPU (CUDA)
```

Key idea: **GPU stays on the host**, not inside Docker.

---

## Prerequisites

- Linux host
- Docker + Docker Compose plugin
- NVIDIA Driver + CUDA
- Ollama installed as **systemd service**
- GPU visible to host (`nvidia-smi` works)

---

## Directory Layout

```
/opt/openwebui/
├── docker-compose.yaml
├── .env
└── README.md
```

---

## Configuration

### `.env`

```env
WEBUI_SECRET_KEY=<long-random-secret>
```

Generate once:

```bash
openssl rand -hex 32
```

⚠️ Do not rotate casually — it invalidates sessions.

Permissions:

```bash
chmod 600 .env
```

---

### `docker-compose.yaml`

- Runs **Open WebUI**
- Runs **Watchtower** (label-based updates only)
- Connects to host Ollama via `host.docker.internal`

No GPU flags are required here.

---

## Ollama (Host Service)

Ollama must listen on an address Docker can reach.

Check:

```bash
ss -lntp | grep 11434
```

Correct:

```bash
0.0.0.0:11434
```

If needed, fix via systemd override:

```bash
sudo systemctl edit ollama
```

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

Reload:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

Verify GPU usage:

```bash
nvidia-smi
ollama run llama3.1
```

---

## Start / Stop

### Start manually

```bash
cd /opt/openwebui
docker compose up -d
```

### Stop

```bash
docker compose down
```

---

## Auto-start on Boot (systemd)

Systemd unit:
`/etc/systemd/system/openwebui.service`

```ini
[Unit]
Description=Open WebUI (Docker Compose)
Wants=docker.service
After=docker.service network-online.target
Requires=docker.service

[Service]
Type=oneshot
WorkingDirectory=/opt/openwebui
ExecStart=/usr/bin/docker compose -f docker-compose.yaml up -d
ExecStop=/usr/bin/docker compose -f docker-compose.yaml down
RemainAfterExit=yes
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Enable:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now openwebui.service
```

Check:

```bash
systemctl status openwebui.service
```

---

## Updates (Watchtower)

- Uses **nickfedor/watchtower** (maintained fork)
- Checks **every 24 hours**
- Updates **only labeled containers**
- No alerts, no notifications
- Cleans up old images automatically

---

## Logs & Debugging

Open WebUI logs:

```bash
docker logs -f openwebui
```

Watchtower logs:

```bash
docker logs watchtower
```

Test Ollama reachability from container:

```bash
docker exec -it openwebui sh -lc 'curl http://host.docker.internal:11434/api/tags'
```

---

## Common Failure Modes

| Symptom           | Cause                     | Fix                   |
| ----------------- | ------------------------- | --------------------- |
| 500 error in UI   | Ollama bound to 127.0.0.1 | Bind to 0.0.0.0       |
| Models not listed | Wrong `OLLAMA_BASE_URL`   | Use host IP           |
| No GPU usage      | Ollama not using CUDA     | Fix host NVIDIA setup |
| Session resets    | Secret changed            | Restore old `.env`    |

---

## Design Rationale

- **GPU outside Docker** → fewer CUDA issues
- **Systemd Ollama** → stable long-running inference
- **Docker only for UI** → easy updates, low risk
- **Label-based Watchtower** → controlled automation

---

## Status

✅ Production-ready for single-host deployment
✅ CUDA verified on host
✅ Safe auto-updates
✅ Clean boot behavior

---
