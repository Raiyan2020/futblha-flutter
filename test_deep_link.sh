#!/bin/bash

# Test Deep Link Script for Futblha
# Usage: ./test_deep_link.sh [android|ios]

PLATFORM=${1:-android}
URL="https://futblha.com/diwaniya/MTI0MTM="

if [ "$PLATFORM" = "android" ]; then
    echo "Testing deep link on Android..."
    echo "URL: $URL"
    echo ""
    echo "Make sure your Android device/emulator is connected and the app is installed."
    echo "Running adb command..."
    
    adb shell am start -a android.intent.action.VIEW -d "$URL"
    
elif [ "$PLATFORM" = "ios" ]; then
    echo "Testing deep link on iOS..."
    echo "URL: $URL"
    echo ""
    echo "Make sure your iOS simulator/device is running and the app is installed."
    echo "Running xcrun simctl command..."
    
    # Get the first available simulator
    SIMULATOR=$(xcrun simctl list devices available | grep "iPhone" | head -1 | sed 's/.*(\(.*\))/\1/' | tr -d ' ')
    
    if [ -z "$SIMULATOR" ]; then
        echo "No iOS simulator found. Please start a simulator first."
        exit 1
    fi
    
    xcrun simctl openurl "$SIMULATOR" "$URL"
    
else
    echo "Invalid platform. Use 'android' or 'ios'"
    echo "Usage: ./test_deep_link.sh [android|ios]"
    exit 1
fi

echo ""
echo "Deep link test command executed!"
echo "Check your app to see if it opened the diwaniya details page."

