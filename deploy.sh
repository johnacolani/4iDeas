#!/bin/bash

# Deployment script for 4iDeas web app

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






