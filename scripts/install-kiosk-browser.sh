#!/bin/bash
# Install dependencies for custom kiosk browser

set -e

echo "📦 Installing PyQt5 and dependencies..."

# Install PyQt5 and QtWebEngine
sudo apt update
sudo apt install -y \
    python3-pyqt5 \
    python3-pyqt5.qtwebengine \
    python3-pyqt5.qtmultimedia

echo ""
echo "✅ Kiosk browser dependencies installed!"
echo ""
echo "📝 To use the custom browser:"
echo "   python3 scripts/kiosk-browser.py http://localhost/"
echo ""
echo "⌨️  Keyboard shortcuts:"
echo "   F11 - Toggle fullscreen"
echo "   F5 - Reload page"
echo "   Ctrl+Q - Quit"
echo "   Esc - Exit fullscreen"
echo ""
