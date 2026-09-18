# ForgeOS: Personal Fedora Silverblue Workstation

A custom, immutable workstation image built on **Fedora Silverblue** using `bootc`, automated via GitHub Actions,
and extended with user-space Homebrew. This image is optimized for Intel based machines but its quite simple to adopt
for Nvidia or AMD. [RPM Fusion](https://rpmfusion.org/) is already included.

---

## 🚀 First-Time Setup & Installation

To switch your machine to your personal GitHub-built image, simply point your deployment target directly to the public
registry.

### 1. Rebase onto ForgeOS

```bash
# Switch your immutable system to your custom image (no login required for public repos)
sudo bootc switch ghcr.io/robertlonnqvist/forgeos:latest

# Reboot to apply the changes
systemctl reboot
```

### 2. Post-Installation: Set Up Homebrew

Because this system is immutable, CLI utilities and developer tools are best managed in user-space via **Homebrew**.
All required compilation tools (`gcc`, `make`, `glibc-devel`) are pre-baked into your ForgeOS image layer so the
installation script will succeed smoothly.

Follow the official installation guide at [brew.sh](https://brew.sh)

---

## 🛠️ Development & Update Workflow

Your operating system configuration is entirely cloud-native. Package layers and system-level configuration files
are managed strictly via Git.

### Making Changes to Your OS

1. Modify the `Containerfile` or drop configuration files into `system_files/` (e.g., adding keys to `/etc`).
2. Verify your changes and build locally
   ```bash
   podman build -t forgeos:local .
   ```
3. Commit and push your changes to GitHub:
   ```bash
   git add .
   git commit -m "chore: optimize configuration and layer packages"
   git push origin main
   ```
4. GitHub Actions will automatically validate (`bootc container lint`), build, and publish your new image layer.

### Pulling System Updates

When GitHub finishes building a new version—or when Fedora pushes regular security updates to its base image—apply
the changes on your physical machine:

```bash
# Pull and stage the latest system build
sudo bootc upgrade

# Reboot into your freshly updated system
systemctl reboot
```

---

## 🔄 Tracking System Changes

To inspect package upgrades, added system utilities, or upstream Fedora changes before or after you reboot, query the
local database diff log:

```bash
rpm-ostree db diff --changelogs
```

