#!/bin/bash

# Deployment script for 4iDeas web app
#
# ServiceFlow tetradic palette (bundled with case study design-system viewer):
#   Primary teal #6FA8A1 · Coral CTA #D98C7A · Purple #7B6F9D · Gold #C9A96E
#   Surfaces: #F5F2EB light · #1A1917 dark

set -e

echo "📋 Syncing ServiceFlow design system (tetradic HTML) into web/ + assets/..."
if [ -f docs/serviceflow-design-system.html ]; then
  mkdir -p web/docs assets/docs
  cp docs/serviceflow-design-system.html web/docs/serviceflow-design-system.html
  cp docs/serviceflow-design-system.html assets/docs/serviceflow-design-system.html
  echo "   → web/docs & assets/docs updated"
else
  echo "   ⚠ docs/serviceflow-design-system.html not found; skipping sync"
fi

echo "🚀 Building 4iDeas web app for production..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "📦 Production files are in: build/web/"
    echo ""
    echo "Choose deployment option:"
    echo "1. Firebase Hosting (recommended)"
    echo "2. Test locally"
    echo ""
    read -p "Enter option (1 or 2): " option
    
    case $option in
        1)
            echo "🔥 Deploying to Firebase Hosting..."
            firebase deploy --only hosting
            ;;
        2)
            echo "🌐 Starting local server..."
            cd build/web
            python3 -m http.server 8080
            echo "App running at: http://localhost:8080"
            ;;
        *)
            echo "Invalid option. Build complete. Deploy manually."
            ;;
    esac
else
    echo "❌ Build failed. Please check errors above."
    exit 1
fi






