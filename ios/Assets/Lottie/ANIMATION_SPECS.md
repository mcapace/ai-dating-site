# Lottie Animation Specifications for Project Jules

## Required Animations

### 1. Splash Screen Animation
- **File**: `splash.json`
- **Duration**: 2-3 seconds
- **Style**: Elegant, warm, welcoming
- **Colors**: Use brand colors (julCream, julTerracotta, julSage)
- **Elements**: 
  - Subtle logo animation
  - Gentle fade-in effect
  - Optional: Soft geometric shapes

### 2. Onboarding Progress Indicator
- **File**: `onboarding-progress.json`
- **Duration**: Loop
- **Style**: Minimal, elegant progress indicator
- **Usage**: Shows progress through onboarding steps
- **Colors**: julTerracotta for active, julCream for inactive

### 3. Match Success Animation
- **File**: `match-success.json`
- **Duration**: 3-4 seconds
- **Style**: Celebratory but sophisticated
- **Trigger**: When two users match
- **Elements**: 
  - Sparkles or confetti (subtle)
  - Heart or connection symbol
  - Smooth easing

### 4. Spark Exchange Animation
- **File**: `spark-sent.json`
- **Duration**: 1-2 seconds
- **Style**: Quick, energetic
- **Trigger**: When user sends a spark
- **Elements**: Spark or lightning bolt animation

### 5. Typing Indicator
- **File**: `typing-indicator.json`
- **Duration**: Loop
- **Style**: Minimal dots animation
- **Usage**: Shows when Jules is "typing"
- **Colors**: julWarmBlack or julTerracotta

### 6. Loading States
- **File**: `loading.json`
- **Duration**: Loop
- **Style**: Subtle, elegant spinner
- **Usage**: General loading states
- **Colors**: julTerracotta

### 7. Empty State Illustrations
- **Files**: 
  - `empty-matches.json`
  - `empty-intros.json`
  - `empty-conversations.json`
- **Duration**: Static or subtle loop
- **Style**: Illustrative, friendly
- **Usage**: When no content is available

### 8. Success Checkmark
- **File**: `success-check.json`
- **Duration**: 1 second
- **Style**: Smooth checkmark animation
- **Usage**: Confirmation states
- **Colors**: julSage (green)

### 9. Error State
- **File**: `error-state.json`
- **Duration**: Static or subtle animation
- **Style**: Friendly, not alarming
- **Usage**: Error messages
- **Colors**: Soft red (not harsh)

## Design Guidelines

- **Frame Rate**: 60fps for smooth animations
- **File Size**: Keep under 200KB per animation when possible
- **Colors**: Use brand palette (julCream, julWarmBlack, julTerracotta, julSage)
- **Style**: Elegant, warm, sophisticated - match the app's premium feel
- **Easing**: Use smooth, natural easing curves (ease-in-out preferred)
- **Looping**: Only loop when necessary (loading, typing indicators)

## Export Settings

- **Format**: JSON (Lottie)
- **Version**: Lottie 5.0+ compatible
- **Assets**: Embed assets in JSON when possible
- **Optimization**: Use Bodymovin optimization settings

## File Naming Convention

- Use kebab-case: `animation-name.json`
- Be descriptive: `match-success.json` not `anim1.json`
- Group related: Prefix with category if needed

## Integration Notes

Animations will be loaded using:
```swift
LottieView(animation: .named("animation-name"))
    .playing(loopMode: .loop) // if needed
```

