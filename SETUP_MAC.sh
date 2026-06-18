#!/bin/bash

# =============================================================
# HoloDesk — Mac Setup Script
# Run this on your Mac after transferring the HoloDesk folder
# =============================================================

echo "🧊 HoloDesk Setup Script"
echo "========================"
echo ""

# Check Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode not found! Install Xcode 27+ from the App Store."
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -1)
echo "✅ Found $XCODE_VERSION"

# Check for visionOS SDK
if xcodebuild -showsdks 2>/dev/null | grep -q "xros"; then
    echo "✅ visionOS SDK found"
else
    echo "⚠️  visionOS SDK not found. Open Xcode → Settings → Platforms → Download visionOS"
fi

echo ""
echo "📁 Setup Instructions:"
echo "========================"
echo ""
echo "1. Open Xcode 27+"
echo "2. File → New → Project"
echo "3. Select: visionOS → App"
echo "4. Settings:"
echo "   • Product Name: HoloDesk"
echo "   • Interface: SwiftUI"
echo "   • Immersive Space: Mixed"
echo "   • ✅ Include RealityKit Content"
echo ""
echo "5. After creating the project, DELETE the default:"
echo "   • ContentView.swift"
echo "   • HoloDeskApp.swift"
echo "   (Xcode creates these, but we have our own)"
echo ""
echo "6. Drag ALL files from the HoloDesk/ folder into Xcode:"
echo "   • Right-click the HoloDesk group in Xcode"
echo "   • Add Files to 'HoloDesk'"
echo "   • Select ALL files/folders:"
echo "     - HoloDeskApp.swift"
echo "     - Models/"
echo "     - Managers/"
echo "     - Views/"
echo "     - Extensions/"
echo "     - Presets/"
echo "     - Resources/"
echo "   • ✅ Check 'Copy items if needed'"
echo "   • ✅ Check 'Create groups'"
echo "   • Click Add"
echo ""
echo "7. Info.plist — Add these keys:"
echo "   • NSHandsTrackingUsageDescription"
echo "     → 'HoloDesk uses hand tracking for spatial gestures'"
echo "   • NSSpeechRecognitionUsageDescription"  
echo "     → 'HoloDesk uses speech recognition for voice commands'"
echo "   • NSMicrophoneUsageDescription"
echo "     → 'HoloDesk needs microphone for voice commands'"
echo "   • NSWorldSensingUsageDescription"
echo "     → 'HoloDesk uses world sensing to place windows in your room'"
echo ""
echo "8. Build & Run:"
echo "   • Select 'Apple Vision Pro' simulator (or device)"
echo "   • Press ⌘R"
echo ""
echo "========================"
echo "🎉 Done! HoloDesk should build and run."
echo ""
echo "Troubleshooting:"
echo "  • If you get 'No such module RealityKit' → Make sure visionOS SDK is installed"
echo "  • If you get 'No such module Observation' → Make sure minimum deployment is visionOS 3.0"
echo "  • If hand tracking doesn't work → Must test on real Vision Pro device"
echo ""
