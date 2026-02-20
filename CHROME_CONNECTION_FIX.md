# Fix: Failed to establish connection with Chrome

This error occurs when Flutter's web tooling cannot establish a WebSocket connection with Chrome for hot reload/restart.

## Quick Fixes (try in order):

### 1. Close all Chrome instances and restart
```bash
# Kill all Chrome processes
killall "Google Chrome" 2>/dev/null || pkill -f "Google Chrome" 2>/dev/null

# Wait a moment, then run Flutter again
flutter run -d chrome
```

### 2. Use a different port
```bash
flutter run -d chrome --web-port=8080
```

### 3. Clear Flutter build cache
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### 4. Disable Chrome extensions temporarily
- Close Chrome completely
- Open Chrome with extensions disabled:
```bash
# macOS
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --disable-extensions

# Then in another terminal, run Flutter
flutter run -d chrome
```

### 5. Check firewall settings
- Make sure your firewall isn't blocking local connections
- Try temporarily disabling the firewall to test

### 6. Use Chrome in remote debugging mode
```bash
# Start Chrome with remote debugging
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222

# In another terminal
flutter run -d chrome --web-port=8080
```

### 7. Use a different browser for testing
```bash
# Check available devices
flutter devices

# Run on Chrome DevTools (if available)
flutter run -d chrome-dev-server
```

### 8. Update Flutter and Chrome
```bash
flutter upgrade
# Also make sure Chrome is up to date
```

### 9. Check for port conflicts
```bash
# Check if port 8080 is in use
lsof -i :8080

# If something is using it, kill it or use a different port
kill -9 <PID>

# Or use a different port
flutter run -d chrome --web-port=9090
```

## Most Common Solution:
Usually, simply closing Chrome completely and restarting it, then running Flutter again, resolves the issue:

```bash
killall "Google Chrome"
flutter run -d chrome --web-port=8080
```

## Alternative: Build and serve manually
If hot reload isn't critical, you can build and serve manually:

```bash
flutter build web
cd build/web
python3 -m http.server 8080
# Then open http://localhost:8080 in Chrome manually
```






