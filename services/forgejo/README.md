# Forgejo

Forgejo with a separate PostgreSQL container and a pre-registered Forgejo Actions runner.

Default ports:

- Web: `http://<server>:3000`
- SSH: `<server>:2222`

Optional server env file:

```bash
sudo install -d -m 0750 /etc/compose
sudo tee /etc/compose/forgejo.env >/dev/null <<'EOF'
FORGEJO_DB_PASSWORD=change-this
FORGEJO_DOMAIN=git.example.com
FORGEJO_ROOT_URL=https://git.example.com/
FORGEJO_SSH_DOMAIN=git.example.com
FORGEJO_SSH_PORT=2222
EOF
sudo chmod 600 /etc/compose/forgejo.env
```

Systemd service:

```bash
sudo systemctl status compose-forgejo.service
```
