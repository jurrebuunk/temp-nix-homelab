# temp-nix-homelab

Temporary NixOS homelab server config.

## What it does

- Builds `nixosConfigurations.server` for `nixos-server`.
- Uses `br0` on `192.168.2.31/24`.
- Enables Docker, Docker Compose, and LXC.
- Auto-updates from `main` every 5 minutes.
- Runs Compose stacks from `services/<app>/compose.yml` as systemd units.

## Deploy now

```bash
sudo nixos-rebuild switch --refresh --flake github:JurreBuunk/temp-nix-homelab/main#server
```

## Compose services

Add stacks like this:

```text
services/<app>/compose.yml
```

NixOS creates a systemd service named:

```text
compose-<app>.service
```

Example checks:

```bash
sudo systemctl status compose-cloudflared.service
sudo systemctl status compose-compose-test.service
docker ps
```

Secrets are loaded from optional env files:

```text
/etc/compose/<app>.env
```

For Cloudflare Tunnel:

```bash
sudo install -d -m 0750 /etc/compose
printf 'TUNNEL_TOKEN=%s\n' '<token>' | sudo tee /etc/compose/cloudflared.env >/dev/null
sudo chmod 600 /etc/compose/cloudflared.env
```

## Validate locally

```bash
nix flake check
nix build .#nixosConfigurations.server.config.system.build.toplevel --no-link
```

CI also validates all `services/**/compose.yml` and `services/**/compose.yaml` files.
