#!/bin/bash

# Script to copy OpenDyslexic fonts to frontend public directory

echo "📚 Setting up OpenDyslexic fonts for dyslexia mode..."

# Source and destination directories
SOURCE_DIR="dyslexia mode/fonts"
DEST_DIR="frontend/public/fonts"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy font files
if [ -d "$SOURCE_DIR" ]; then
    echo "Copying fonts from $SOURCE_DIR to $DEST_DIR..."
    cp "$SOURCE_DIR/OpenDyslexic-Regular.otf" "$DEST_DIR/" 2>/dev/null && echo "✓ OpenDyslexic-Regular.otf"
    cp "$SOURCE_DIR/OpenDyslexic-Bold.otf" "$DEST_DIR/" 2>/dev/null && echo "✓ OpenDyslexic-Bold.otf"
    cp "$SOURCE_DIR/OpenDyslexic-Italic.otf" "$DEST_DIR/" 2>/dev/null && echo "✓ OpenDyslexic-Italic.otf"
    cp "$SOURCE_DIR/OpenDyslexic-BoldItalic.otf" "$DEST_DIR/" 2>/dev/null && echo "✓ OpenDyslexic-BoldItalic.otf"
    echo "✅ Fonts copied successfully!"
else
    echo "❌ Error: Source directory '$SOURCE_DIR' not found"
    echo "Please ensure the 'dyslexia mode' folder exists with the font files"
    exit 1
fi

echo ""
echo "🎉 Dyslexia mode fonts are now ready!"
echo "The dyslexia toggle button will appear in the bottom-right corner of the application."
