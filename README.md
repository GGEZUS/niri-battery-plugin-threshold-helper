# noctalia-battery-plugin-threshold-auto-discharge

[![Noctalia](https://img.shields.io/badge/Noctalia-Shell-blue)](https://noctalia.dev/)
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-blue)](https://archlinux.org/)

Automatic battery discharge helper for Linux laptops. Works with the [Noctalia Battery Threshold plugin](https://noctalia.dev/plugins/battery-threshold) to actively discharge your battery when it's above the set threshold while connected to AC power.

## About the Plugin

This helper is designed to work with **Battery Threshold Control** plugin for Noctalia Shell by [Wilfred Mallawa](https://github.com/wilfred-mallawa).

**Plugin URL:** https://noctalia.dev/plugins/battery-threshold

**Plugin Features:**
- Bar widget showing current battery threshold
- Panel with slider to adjust threshold (40-100%)
- Persistent settings across reboots

### What This Helper Adds

While the plugin controls the threshold, it doesn't actively discharge an already-full battery to reach that threshold. This helper fills that gap by automatically forcing discharge when:

- Your battery is above the set threshold (e.g., 100% vs 65% target)
- AC power is connected

## Features

- **Auto-discharge to threshold**: When AC is connected and battery is above threshold, actively discharges to the target level
- **Plugin integration**: Reads directly from `charge_control_end_threshold` — works seamlessly with Noctalia plugin
- **Set and forget**: Runs in background via systemd, automatically adapts to your plugin settings
- **Safe operation**: Returns to auto mode when on battery power or threshold is reached

## Why?

Many modern laptops support battery charge thresholds to prolong battery life. However, when you set a threshold (e.g., 65%) while your battery is at 100%, it stays at 100% until you manually discharge it by using the laptop on battery.

This helper solves that by automatically discharging to your target threshold when on AC power.

## Requirements

### Hardware
- **Laptop with battery charge control** (`charge_control_end_threshold` support)
- **Battery charge behaviour control** (`force-discharge` mode support)

Tested on laptops with:
- **Lenovo ThinkPad T480** (Arch Linux + Niri + Noctalia)
- `/sys/class/power_supply/BAT1/charge_control_end_threshold`
- `/sys/class/power_supply/BAT1/charge_behaviour` with `force-discharge` option

### Software
- **Noctalia Shell** 3.6.0 or later (or any Wayland compositor with the plugin)
- **Battery Threshold Control** plugin by Wilfred Mallawa
- Linux distribution with systemd support

## Installation

### Prerequisites

First, install and setup the [Battery Threshold plugin](https://noctalia.dev/plugins/battery-threshold):

1. Install the plugin following instructions on [noctalia.dev](https://noctalia.dev/plugins/battery-threshold)
2. Run the plugin's `setup_rules.sh` to configure write access **(optional - see below)**

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/GGEZUS/noctalia-battery-plugin-threshold-auto-discharge/main/install.sh | bash
```

### Manual Install

1. **Clone the repo:**
   ```bash
   git clone https://github.com/GGEZUS/noctalia-battery-plugin-threshold-auto-discharge.git
   cd noctalia-battery-plugin-threshold-auto-discharge
   ```

2. **Run the installer:**
   ```bash
   ./install.sh
   ```

The installer will:
- **Optionally** install udev rules for write access (skipped if already present)
- Install the monitoring script
- Install and enable the systemd service
- Create log directory

**Note:** If you've already run the plugin's `setup_rules.sh`, the installer will detect existing udev rules and ask if you want to reinstall them. You can safely skip this step.

## Usage

1. **Set your battery threshold** using the Noctalia plugin (e.g., set to 65%)
2. **Connect AC power**
3. **Done!** The helper will automatically discharge to your threshold

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│  Plugin threshold: 65%                                       │
│  Current battery: 100%                                      │
│  AC: Connected                                              │
├─────────────────────────────────────────────────────────────┤
│  → Force discharge until battery reaches 65%               │
│  → Switch to auto mode at 65%                               │
│  → Maintain 65% while on AC                                 │
└─────────────────────────────────────────────────────────────┘
```

### Monitor Progress

```bash
# Check service status
sudo systemctl status battery-auto-discharge

# View logs
tail -f ~/.local/share/battery-auto-discharge/log

# Check current battery percentage
cat /sys/class/power_supply/BAT1/capacity

# Check current charge behaviour
cat /sys/class/power_supply/BAT1/charge_behaviour
```

## Uninstallation

```bash
./uninstall.sh
```

Or manually:
```bash
sudo systemctl disable --now battery-auto-discharge
sudo rm /etc/systemd/system/battery-auto-discharge.service
sudo rm /usr/local/bin/battery-auto-discharge
sudo rm /etc/udev/rules.d/99-battery-threshold.rules
sudo udevadm control --reload-rules
rm -rf ~/.local/share/battery-auto-discharge
```

## Troubleshooting

### Service not running

```bash
sudo systemctl status battery-auto-discharge
sudo journalctl -u battery-auto-discharge -n 50
```

### Permissions denied

Make sure udev rules are loaded:
```bash
ls -l /sys/class/power_supply/BAT1/charge_behaviour
# Should show -rw-rw-rw-
```

If not, reload:
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=power_supply
```

### Battery not discharging

Check if your laptop supports `force-discharge`:
```bash
cat /sys/class/power_supply/BAT1/charge_behaviour
```

Should show: `[auto] inhibit-charge force-discharge`

If `force-discharge` is missing, your laptop may not support this feature.

### Plugin not working

See the [plugin's troubleshooting section](https://noctalia.dev/plugins/battery-threshold):
- Ensure udev rule is installed
- Check you're in the correct group
- Verify your laptop supports charge threshold control
- Try selecting the correct battery in plugin settings

## Configuration

Default settings work for most users. The script checks every 10 seconds:

- **Battery path:** `/sys/class/power_supply/BAT1`
- **Check interval:** 10 seconds
- **Log location:** `~/.local/share/battery-auto-discharge/log`

To customize, edit `/usr/local/bin/battery-auto-discharge` and restart the service.

## Credits

- **Plugin:** [Battery Threshold Control](https://noctalia.dev/plugins/battery-threshold) by [Wilfred Mallawa](https://github.com/wilfred-mallawa)
- **Noctalia Shell:** [noctalia.dev](https://noctalia.dev/)

## Contributing

Contributions welcome! Feel free to open issues or PRs.

## License

MIT License - feel free to use and modify as needed.

## Acknowledgments

- Works with [Noctalia Battery Threshold plugin](https://noctalia.dev/plugins/battery-threshold) by Wilfred Mallawa
- Inspired by the need for better battery management on Linux laptops
