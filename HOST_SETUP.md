# Setting up 4iDeas Local Hostname

To access your Flutter web app using the "4iDeas" name locally, you can add a custom hostname to your `/etc/hosts` file.

## Option 1: Run the setup script (Recommended)

```bash
sudo ./setup_local_host.sh
```

This will add `4ideas.local` pointing to `127.0.0.1` in your `/etc/hosts` file.

## Option 2: Manual setup

1. Open `/etc/hosts` file with admin privileges:
   ```bash
   sudo nano /etc/hosts
   # or
   sudo vim /etc/hosts
   ```

2. Add this line at the end:
   ```
   127.0.0.1    4ideas.local
   ```

3. Save and exit the file.

## Running your app with the custom hostname

After adding the hostname entry, you can run your Flutter web app with:

```bash
flutter run -d chrome --web-hostname=4ideas.local --web-port=8080
```

Then access your app at: **http://4ideas.local:8080**

## Alternative: Use localhost with a custom port

If you prefer to use localhost, you can simply run:

```bash
flutter run -d chrome --web-port=8080
```

And access at: **http://localhost:8080**

## Note

- The `/etc/hosts` file is a system file, so you'll need admin/sudo privileges to modify it
- After adding the entry, you may need to restart your browser or clear DNS cache
- On macOS, you can flush DNS cache with: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`






