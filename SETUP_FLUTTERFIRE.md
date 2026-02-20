# Quick Setup: FlutterFire CLI

## Step 1: Install FlutterFire CLI

Run this command:

```bash
dart pub global activate flutterfire_cli
```

## Step 2: Add to PATH (for zsh)

Since you're using zsh, add this to your PATH. Run:

```bash
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

## Step 3: Verify Installation

```bash
flutterfire --version
```

If you see a version number, you're good to go!

## Step 4: Run FlutterFire Configure

```bash
cd /Users/johncolani/flutter_project_oct_24/my_web_site
flutterfire configure
```

## Alternative: If PATH doesn't work

You can also run FlutterFire directly:

```bash
dart pub global run flutterfire_cli:flutterfire configure
```

## Troubleshooting

### If `dart pub global activate` fails:
Make sure Dart/Flutter is properly installed:
```bash
which dart
which flutter
flutter doctor
```

### If PATH still doesn't work:
Try finding where pub-cache is:
```bash
dart pub cache list
```

The bin directory should be at: `$HOME/.pub-cache/bin` or `/Users/johncolani/.pub-cache/bin`

### Manual PATH check:
```bash
echo $HOME/.pub-cache/bin
ls $HOME/.pub-cache/bin/flutterfire
```

If the file exists, you can either:
1. Add that directory to PATH (preferred)
2. Run it directly: `$HOME/.pub-cache/bin/flutterfire configure`






