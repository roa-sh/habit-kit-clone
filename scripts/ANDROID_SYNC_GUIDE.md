# Android Usage Data Sync Guide

Sync your Android tablet's app usage data to your Raspberry Pi wirelessly.

## Prerequisites

- Android tablet (Android 5.0+)
- Raspberry Pi with backend running
- Same Wi-Fi network for both devices

## Installation

### On Raspberry Pi:

```bash
cd /path/to/habit-kit-clone
./scripts/install-android-sync.sh
cd backend
rails db:migrate
```

### On Android Tablet:

#### 1. Enable Developer Options
- Settings → About tablet
- Tap **Build number** 7 times
- Go to Settings → System → Developer options

#### 2. Enable Wireless Debugging

**For Android 11+ (Most Common):**

1. Turn on **USB debugging**
2. Turn on **Wireless debugging**
3. **IMPORTANT:** Tap **"Pair device with pairing code"**
4. Note the **6-digit code** and the **IP:PORT** shown (e.g., `192.168.40.150:37853`)

**For Android 10 and below:**

You'll need to temporarily connect via USB to any computer with ADB, run `adb tcpip 5555`, then disconnect.

#### 3. Choose Connection Method

**Option A: Static IP (Recommended)**
- Settings → Wi-Fi → Long-press network → Modify network
- Advanced options → IP settings → Static
- Set IP (e.g., `192.168.1.150`), Gateway (e.g., `192.168.1.1`), DNS (`8.8.8.8`)
- Edit `/etc/android-sync.conf` on Pi and set `ANDROID_STATIC_IP="192.168.1.150"`

**Option B: Auto-Discovery**
- Do nothing, script will find tablet automatically (takes ~30 seconds)

## Configuration

Edit `/etc/android-sync.conf`:

```bash
ANDROID_STATIC_IP="192.168.1.150"  # Leave empty if using auto-discovery
ANDROID_DEVICE_NAME="android"
BACKEND_URL="http://localhost:3000/api/usage"
DAYS_BACK=1  # Use 1 for minute-by-minute syncing (only today's data)
```

## Pair Device (Android 11+ Only - Do This Once)

Android 11+ uses TWO different ports: one for pairing, one for connecting.

**Step 1: Pair (one-time)**

On tablet: Settings → Developer options → Wireless debugging → **Pair device with pairing code**
- Note **6-digit code** and **pairing port** (e.g., `192.168.40.150:43003`)

On Pi:
```bash
adb pair 192.168.40.150:43003  # Use pairing port from tablet
# Enter 6-digit code when prompted
```

**Step 2: Connect (every time)**

On tablet: Look at main **Wireless debugging** screen (not pairing dialog)
- Note **connection port** (e.g., `192.168.40.150:43243`) - this is different!

On Pi:
```bash
adb connect 192.168.40.150:43243  # Use connection port from tablet
adb devices  # Should show: device (not offline)
```

**Step 3: Update config**
```bash
sudo nano /etc/android-sync.conf
```
Add your connection port:
```bash
ANDROID_STATIC_IP="192.168.40.150"
ANDROID_ADB_PORT="43243"  # Your connection port
```

**Note:** Connection port may change after tablet restart. Check Wireless debugging screen if sync stops working.

## Test

```bash
export $(cat /etc/android-sync.conf | xargs)
cd /path/to/habit-kit-clone
./scripts/sync-android-usage.sh
```

Expected output:
```
✓ Connected via static IP
✓ Successfully extracted data for 25 apps
✓ Data successfully sent to backend
```

Verify data:
```bash
curl http://localhost:3000/api/usage/summary
```

## Automatic Syncing

By default syncs every hour. To update to **every minute** for real-time data:

```bash
cd /path/to/habit-kit-clone
./scripts/update-sync-frequency.sh
```

Check status:

```bash
sudo systemctl status android-sync.timer
```

## Accessing Data

### API Endpoints

```bash
# Get today's usage for a specific app (real-time)
curl http://localhost:3000/api/usage/today/com.google.android.youtube
# Returns: "You've been using YouTube for 370 minutes today"

# Summary of last 7 days
curl http://localhost:3000/api/usage/summary

# Detailed stats
curl http://localhost:3000/api/usage?days=7

# All data for specific app
curl "http://localhost:3000/api/usage?package=com.google.android.youtube"
```

**Example response for today's usage:**
```json
{
  "success": true,
  "package": "com.google.android.youtube",
  "app_name": "YouTube",
  "total_time_ms": 22200000,
  "total_time_minutes": 370,
  "total_time_hours": 6.17,
  "last_updated": "2026-01-13T15:30:00.000Z",
  "message": "You've been using YouTube for 370 minutes today"
}
```

### Rails Console

```bash
cd backend
rails console
```

```ruby
# Today's usage for YouTube
youtube = AppUsage.for_package('com.google.android.youtube')
  .where('recorded_at >= ?', Time.zone.now.beginning_of_day)
  .order(recorded_at: :desc)
  .first
puts "You've been using YouTube for #{youtube.time_in_minutes.round(0)} minutes today"

# Top 10 apps today
AppUsage.today.group(:package_name)
  .maximum(:total_time_ms)
  .sort_by { |_, time| -time }
  .first(10)

# All today's apps
AppUsage.today.group(:package_name).maximum(:total_time_ms)
```

## Monitoring

```bash
# View logs
journalctl -u android-sync.service -f

# Manual sync
sudo systemctl start android-sync.service

# Check backups
ls -lht /tmp/android-usage-*.json | head
```

## Troubleshooting

### Can't Connect

```bash
# Check ADB
adb devices

# If nothing shows, restart ADB
adb kill-server
adb start-server
```

**Solutions:**
- Check tablet and Pi are on same Wi-Fi network
- Look for "Allow USB debugging?" popup on tablet (for wireless debugging authorization)
- Set static IP instead of relying on auto-discovery

### "device unauthorized"
- Look at tablet screen and tap "Allow"
- Check "Always allow from this computer"

### No Usage Data

Grant permission on Android:
- Settings → Apps → Special access → Usage access
- Enable for "Shell" or "Android System"

### Backend Not Receiving Data

```bash
# Check backend is running
curl http://localhost:3000/api/usage/summary

# Check migration ran
cd backend && rails db:migrate:status

# Test endpoint
curl -X POST http://localhost:3000/api/usage \
  -H "Content-Type: application/json" \
  -d '{"apps":[{"package":"test","totalTimeMs":1000}]}'
```

### IP Keeps Changing

Set static IP on your tablet (see Step 3 above).

## How Dynamic IPs Are Handled

Script tries 3 methods in order:
1. Static IP (if configured)
2. mDNS hostname resolution
3. Network scan (takes ~30 seconds)

**Recommendation:** Set static IP for reliable connection.
