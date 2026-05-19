#!/usr/bin/env bash
set -e

echo "🔋 Niri Battery Plugin Threshold Helper - Installer"
echo "=================================================="
echo

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "❌ Please don't run this script as root. It will use sudo when needed."
    exit 1
fi

# Check if required files exist
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES=("battery-auto-discharge" "battery-auto-discharge.service" "99-battery-threshold.rules")

for file in "${FILES[@]}"; do
    if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
        echo "❌ Missing file: $file"
        exit 1
    fi
done

echo "✅ All required files found"
echo

# Check battery support
echo "🔍 Checking battery support..."
if [[ ! -f /sys/class/power_supply/BAT1/charge_control_end_threshold ]]; then
    echo "❌ Your battery doesn't support charge control"
    exit 1
fi

if [[ ! -f /sys/class/power_supply/BAT1/charge_behaviour ]]; then
    echo "❌ Your battery doesn't support charge behaviour control"
    exit 1
fi

if ! grep -q "force-discharge" /sys/class/power_supply/BAT1/charge_behaviour; then
    echo "❌ Your battery doesn't support force-discharge mode"
    exit 1
fi

echo "✅ Battery supports required features"
echo

# Install udev rules
echo "📦 Installing udev rules..."
sudo cp "$SCRIPT_DIR/99-battery-threshold.rules" /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=power_supply
echo "✅ Udev rules installed"
echo

# Install script
echo "📦 Installing monitoring script..."
sudo cp "$SCRIPT_DIR/battery-auto-discharge" /usr/local/bin/
sudo chmod +x /usr/local/bin/battery-auto-discharge
echo "✅ Script installed"
echo

# Get current username
USER=$(whoami)

# Create systemd service with correct user
echo "📦 Installing systemd service..."
sed "s/User=rbc/User=$USER/g" "$SCRIPT_DIR/battery-auto-discharge.service" | \
    sed "s|/home/rbc/.local/share|$HOME/.local/share|g" | \
    sudo tee /etc/systemd/system/battery-auto-discharge.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable battery-auto-discharge.service
sudo systemctl start battery-auto-discharge.service
echo "✅ Service installed and started"
echo

# Check service status
sleep 2
if sudo systemctl is-active --quiet battery-auto-discharge.service; then
    echo "✅ Service is running"
else
    echo "⚠️  Service may not be running. Check with: sudo systemctl status battery-auto-discharge"
fi

echo
echo "🎉 Installation complete!"
echo
echo "Next steps:"
echo "  1. Set your battery threshold using your Niri widget"
echo "  2. Connect AC power"
echo "  3. Monitor progress: tail -f ~/.local/share/battery-auto-discharge/log"
echo
echo "For troubleshooting, see README.md"
