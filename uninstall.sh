#!/usr/bin/env bash
set -e

echo "🗑️  Niri Battery Plugin Threshold Helper - Uninstaller"
echo "======================================================"
echo

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "❌ Please don't run this script as root. It will use sudo when needed."
    exit 1
fi

echo "This will remove:"
echo "  - Systemd service: battery-auto-discharge"
echo "  - Monitoring script: /usr/local/bin/battery-auto-discharge"
echo "  - Udev rules: /etc/udev/rules.d/99-battery-threshold.rules"
echo "  - Log directory: ~/.local/share/battery-auto-discharge"
echo

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Stop and disable service
echo "🛑 Stopping and disabling service..."
sudo systemctl disable --now battery-auto-discharge.service 2>/dev/null || true
echo "✅ Service stopped"

# Remove service file
echo "🗑️  Removing service file..."
sudo rm -f /etc/systemd/system/battery-auto-discharge.service
sudo systemctl daemon-reload
echo "✅ Service removed"

# Remove script
echo "🗑️  Removing monitoring script..."
sudo rm -f /usr/local/bin/battery-auto-discharge
echo "✅ Script removed"

# Remove udev rules
echo "🗑️  Removing udev rules..."
sudo rm -f /etc/udev/rules.d/99-battery-threshold.rules
sudo udevadm control --reload-rules
echo "✅ Udev rules removed"

# Remove log directory
echo "🗑️  Removing log directory..."
rm -rf "$HOME/.local/share/battery-auto-discharge"
echo "✅ Logs removed"

echo
echo "🎉 Uninstallation complete!"
echo "Thank you for using niri-battery-plugin-threshold-helper!"
