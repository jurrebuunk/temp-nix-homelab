# NixOS Homelab Server

NixOS configuration for the homelab server.

## Structure

```text
.
├── configuration.nix
├── hardware-configuration.nix
├── flake.nix
├── flake.lock
├── modules/
│   ├── docker.nix
│   ├── lan-bridge.nix
│   └── lxc.nix
└── .github/
    └── workflows/
        └── nixos-check.yml
```

## Server

Flake target:

```text
server
```

Hostname:

```text
nixos-server
```

Network:

```text
Interface: br0
IP:        192.168.2.31/24
Gateway:   192.168.2.254
DNS:       192.168.2.254, 1.1.1.1
```

The physical Ethernet interface is attached to `br0`. Docker and LXC are enabled.

## Initial deployment

From the server:

```bash
sudo nixos-rebuild switch --flake github:JurreBuunk/temp-nix-homelab#server
```

Or clone the repository:

```bash
git clone https://github.com/jurrebuunk/temp-nix-homelab.git
cd temp-nix-homelab

sudo nixos-rebuild switch --flake .#server
```

## Test configuration

Build without activating:

```bash
sudo nixos-rebuild build --flake .#server
```

Check the flake:

```bash
nix flake check
```

## Apply changes manually

```bash
git pull
sudo nixos-rebuild switch --flake .#server
```

To deploy directly from GitHub:

```bash
sudo nixos-rebuild switch --flake github:JurreBuunk/temp-nix-homelab/main#server
```

## Automatic deployment

The server checks:

```text
github:JurreBuunk/temp-nix-homelab/main#server
```

every 5 minutes.

If the configuration changed and builds successfully, NixOS switches to the new configuration.

Check the timer:

```bash
systemctl list-timers | grep nixos-upgrade
```

Run it manually:

```bash
sudo systemctl start nixos-upgrade.service
```

View logs:

```bash
journalctl -u nixos-upgrade.service
```

## CI

GitHub Actions runs on:

* pushes to `main`
* pull requests targeting `main`

It runs:

```bash
nix flake check
```

and builds:

```bash
nix build .#nixosConfigurations.server.config.system.build.toplevel --no-link
```

Only merge changes that pass CI.

## Docker

Docker and Docker Compose are installed.

```bash
docker --version
docker compose version
```

The `jurre` user is in the `docker` group.

Unused Docker data older than 7 days is pruned weekly.

## LXC

LXC is installed and configured to use:

```text
br0
```

Containers can therefore connect directly to the LAN.

List containers:

```bash
lxc-ls --fancy
```

Start a container:

```bash
lxc-start -n <name>
```

Stop it:

```bash
lxc-stop -n <name>
```

Attach:

```bash
lxc-attach -n <name>
```

## Updating nixpkgs

Update `flake.lock`:

```bash
nix flake update
```

Test:

```bash
nix flake check
sudo nixos-rebuild build --flake .#server
```

Then commit and push:

```bash
git add flake.lock
git commit -m "Update nixpkgs"
git push
```
