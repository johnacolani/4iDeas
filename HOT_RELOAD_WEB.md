# Hot Reload and Hot Restart for Flutter Web

Hot reload and hot restart work automatically when running Flutter web. No additional configuration is needed!

## Running the App

```bash
flutter run -d chrome
```

Or to specify a port:
```bash
flutter run -d chrome --web-port=8080
```

## Hot Reload / Hot Restart Commands

While your Flutter app is running in Chrome, you can use these commands in the terminal:

### Hot Reload (Preserves State)
Press **`r`** in the terminal to hot reload:
- Fast refresh (usually < 1 second)
- Preserves app state
- Use for most code changes
- Works for: UI changes, method implementations, etc.

### Hot Restart (Resets State)
Press **`R`** (capital R) in the terminal to hot restart:
- Full restart (takes a few seconds)
- Resets app state
- Use when hot reload doesn't work
- Needed for: initializer changes, constructor changes, etc.

### Other Useful Commands

- **`h`** - Show help menu
- **`q`** - Quit and stop the app
- **`c`** - Clear the terminal screen
- **`v`** - Open DevTools

## Enable Hot Reload in Chrome DevTools

You can also enable hot reload directly in Chrome:

1. Open Chrome DevTools (F12 or Cmd+Option+I)
2. Look for the Flutter DevTools extension (if installed)
3. Or use the terminal commands above

## Tips for Better Hot Reload Performance

1. **Use `--web-renderer html` for faster reloads:**
   ```bash
   flutter run -d chrome --web-renderer html
   ```

2. **Use `--web-renderer canvaskit` for better performance (slower reloads):**
   ```bash
   flutter run -d chrome --web-renderer canvaskit
   ```

3. **Default renderer** (auto-detects):
   ```bash
   flutter run -d chrome
   ```

## When Hot Reload Doesn't Work

If hot reload (`r`) doesn't work, try:
1. **Hot restart** (`R`) - Resets the entire app
2. **Full restart** - Stop (press `q`) and run again

## Troubleshooting

### Hot Reload Not Working
- Make sure you're in the terminal where `flutter run` is active
- Check that the app is still running
- Try hot restart (`R`) instead

### Changes Not Appearing
- Press `r` for hot reload
- If that doesn't work, press `R` for hot restart
- Check browser console for errors (F12)

### App Crashed
- Stop the app (press `q`)
- Run again: `flutter run -d chrome`

## Development Mode vs Release Mode

**Development Mode (default):**
```bash
flutter run -d chrome
```
- Hot reload enabled
- Debug mode
- Slower performance
- Full error messages

**Release Mode:**
```bash
flutter run -d chrome --release
```
- No hot reload
- Optimized performance
- Production build

## Browser Compatibility

Hot reload works with:
- ✅ Chrome/Chromium (recommended)
- ✅ Edge (Chromium-based)
- ✅ Firefox
- ✅ Safari (macOS)

Just run: `flutter run -d <browser>`

## Quick Reference

| Action | Command |
|--------|---------|
| Hot Reload | Press `r` |
| Hot Restart | Press `R` |
| Stop App | Press `q` |
| Help | Press `h` |
| Clear Screen | Press `c` |
| Open DevTools | Press `v` |






