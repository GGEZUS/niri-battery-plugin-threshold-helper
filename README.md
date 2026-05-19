# niri-battery-widget-threshold-helper

[![Niri](https://img.shields.io/badge/Niri-Window%20Manager-blue)](https://github.com/YaLTeR/niri)
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-blue)](https://archlinux.org/)

Automatic battery discharge helper for Niri window manager on Arch Linux. Works with battery threshold widgets to actively discharge your battery when it's above the set threshold while connected to AC power.

## Features

- **Auto-discharge to threshold**: When AC is connected and battery is above the widget's threshold, actively discharges to the target level
- **Widget integration**: Reads directly from `charge_control_end_threshold` - works with any battery widget
- **Set and forget**: Runs in background via systemd, automatically adapts to your widget settings
- **Safe operation**: Returns to auto mode when on battery power or threshold is reached

## Why?

Many modern laptops support battery charge thresholds to prolong battery life. However, when you set a threshold (e.g., 65%) while your battery is at 100%, it stays at 100% until you manually discharge it by using the laptop on battery.

This helper solves that by automatically discharging to your target threshold when on AC power.

## Requirements

- **Niri** window manager on Arch Linux
- **Laptop with battery charge control** (`charge_control_end_threshold` support)
- **Battery charge behaviour control** (`force-discharge` mode support)

Tested on laptops with:
- `/sys/class/power_supply/BAT1/charge_control_end_threshold`
- `/sys/class/power_supply/BAT1/charge_behaviour` with `force-discharge` option

## Installation

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/GGEZUS/niri-battery-widget-threshold-helper/main/install.sh | bash
```

### Manual Install

1. **Clone the repo:**
   ```bash
   git clone https://github.com/GGEZUS/niri-battery-widget-threshold-helper.git
   cd niri-battery-widget-threshold-helper
   ```

2. **Run the installer:**
   ```bash
   ./install.sh
   ```

The installer will:
- Install udev rules for write access
- Install the monitoring script
- Install and enable the systemd service
- Create log directory

## Usage

1. **Set your battery threshold** using your Niri widget (e.g., set to 65%)
2. **Connect AC power**
3. **Done!** The helper will automatically discharge to your threshold

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│  Widget threshold: 65%                                       │
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

## Configuration

Default settings work for most users. The script checks every 10 seconds:

- **Battery path:** `/sys/class/power_supply/BAT1`
- **Check interval:** 10 seconds
- **Log location:** `~/.local/share/battery-auto-discharge/log`

To customize, edit `/usr/local/bin/battery-auto-discharge` and restart the service.

## Contributing

Contributions welcome! Feel free to open issues or PRs.

## License

MIT License - feel free to use and modify as needed.

## Acknowledgments

- Built for [Niri](https://github.com/YaLTeR/niri) window manager
- Inspired by the need for better battery management on Linux laptops
