# Fix Signing Issue - Quick Steps

## The Problem
Xcode requires a development team to sign the app for running on simulators or devices.

## Quick Fix (30 seconds)

1. **In Xcode**, click on **"ProjectJules"** (the blue project icon) in the left sidebar

2. **Select the "ProjectJules" target** in the main area

3. **Click on "Signing & Capabilities" tab**

4. **Check "Automatically manage signing"** ✅

5. **Under "Team"**, select your Apple Developer team:
   - If you see your team, select it
   - If you don't see your team:
     - Click "Add Account..." 
     - Sign in with your Apple ID
     - Select your team after signing in

6. **Done!** ✅

## If You Don't Have an Apple Developer Account

For **simulator testing only**, you can use your personal Apple ID:

1. Follow steps 1-4 above
2. Click "Add Account..."
3. Sign in with your **personal Apple ID** (free)
4. Select your name as the team
5. Xcode will automatically create a provisioning profile

**Note:** Using a personal Apple ID:
- ✅ Works for simulator testing
- ✅ Works for device testing (with your own devices)
- ❌ Cannot distribute to App Store
- ❌ Devices need to be registered (Xcode will prompt you)

## Verify It Works

After setting up signing:
1. **Build** (⌘B) - should succeed
2. **Run** (⌘R) - app should launch on simulator/device

## Troubleshooting

**"No accounts with Apple ID" error:**
- Go to Xcode → Settings → Accounts
- Click "+" to add your Apple ID
- Sign in with your Apple ID

**"Failed to create provisioning profile":**
- Make sure "Automatically manage signing" is checked
- Try cleaning build folder (Shift+⌘+K) and rebuilding

**"Your account already has a maximum number of registered devices":**
- This is a limitation of free Apple ID accounts
- You can remove old devices at: https://developer.apple.com/account/resources/devices/list

## That's It!

Once you select a team, signing is configured and the app will build and run! 🎉

