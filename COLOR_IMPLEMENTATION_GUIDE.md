# How to Update Your Screens with Professional Colors

## Quick Reference

Your new color system is in: `lib/utils/app_colors.dart`

### Import in Any Screen:
```dart
import 'package:safety_safar_app/utils/app_colors.dart';
```

---

## Color Usage Examples

### 1. **Login/Registration Screens**

Replace old hardcoded colors:
```dart
// ❌ OLD
backgroundColor: const Color(0xFF0A0E14),
color: const Color(0xFF0E3A7E),

// ✅ NEW
backgroundColor: AppColors.backgroundLight,
color: AppColors.primaryDeepBlue,
```

### 2. **Buttons**

```dart
// Primary Button (Safe, Approve, Continue)
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryDeepBlue,
    foregroundColor: AppColors.white,
  ),
  child: const Text('Continue'),
)

// Success/Approved Button
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.successGreen,
    foregroundColor: AppColors.white,
  ),
  child: const Text('Approved'),
)

// Warning/Pending Button
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.amberGold,
    foregroundColor: AppColors.white,
  ),
  child: const Text('Review Required'),
)

// Danger/SOS Button
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.emergencyRed,
    foregroundColor: AppColors.white,
  ),
  child: const Text('Emergency SOS'),
)
```

### 3. **Text**

```dart
// Headlines
Text(
  'Safety Status',
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    color: AppColors.textDark,
  ),
)

// Body Text
Text(
  'Your current location is verified and safe',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: AppColors.textMedium,
  ),
)

// Secondary Text
Text(
  'Verified 2 minutes ago',
  style: Theme.of(context).textTheme.bodySmall?.copyWith(
    color: AppColors.textLight,
  ),
)
```

### 4. **Status Indicators**

```dart
// Verified/Safe Status
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.successGreen.withOpacity(0.1),
    border: Border.all(color: AppColors.successGreen),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check_circle, color: AppColors.successGreen, size: 16),
      const SizedBox(width: 8),
      Text(
        'Verified',
        style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.w600),
      ),
    ],
  ),
)

// Pending Status
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.amberGold.withOpacity(0.1),
    border: Border.all(color: AppColors.amberGold),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    'Pending Review',
    style: TextStyle(color: AppColors.amberGold, fontWeight: FontWeight.w600),
  ),
)

// Emergency Status
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.emergencyRed.withOpacity(0.1),
    border: Border.all(color: AppColors.emergencyRed),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    'Emergency Alert',
    style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.w600),
  ),
)
```

### 5. **Cards & Containers**

```dart
// Standard Card
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: AppColors.textLight),
  ),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Text('Card Content'),
  ),
)

// Highlighted Card (Important)
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.primaryDeepBlue.withOpacity(0.05),
    border: Border.all(
      color: AppColors.primaryDeepBlue.withOpacity(0.3),
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Text('Important Information'),
)
```

### 6. **Alert Dialogs**

```dart
// Success Alert
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: AppColors.white,
    title: Row(
      children: [
        Icon(Icons.check_circle, color: AppColors.successGreen),
        const SizedBox(width: 12),
        const Text('Success', style: TextStyle(color: AppColors.textDark)),
      ],
    ),
    content: const Text('Operation completed successfully'),
    actions: [
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
        ),
        child: const Text('OK'),
      ),
    ],
  ),
)

// Error Alert
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: AppColors.white,
    title: Row(
      children: [
        Icon(Icons.error_outline, color: AppColors.emergencyRed),
        const SizedBox(width: 12),
        const Text('Error', style: TextStyle(color: AppColors.textDark)),
      ],
    ),
    content: const Text('Something went wrong'),
    actions: [
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emergencyRed,
        ),
        child: const Text('Retry'),
      ),
    ],
  ),
)

// Warning Alert
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: AppColors.white,
    title: Row(
      children: [
        Icon(Icons.warning_outline, color: AppColors.warningOrange),
        const SizedBox(width: 12),
        const Text('Warning', style: TextStyle(color: AppColors.textDark)),
      ],
    ),
    content: const Text('Please review before proceeding'),
    actions: [
      OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warningOrange,
        ),
        child: const Text('Proceed'),
      ),
    ],
  ),
)
```

### 7. **AppBar & Header**

```dart
AppBar(
  backgroundColor: AppColors.primaryDeepBlue,
  foregroundColor: AppColors.white,
  title: const Text('Safety Safar'),
  elevation: 0,
  actions: [
    IconButton(
      onPressed: () {},
      icon: const Icon(Icons.notifications_none),
      color: AppColors.white,
    ),
  ],
)
```

### 8. **Form Inputs**

```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Enter your name',
    prefixIcon: const Icon(Icons.person),
    prefixIconColor: AppColors.primaryDeepBlue,
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.textLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primaryDeepBlue,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.emergencyRed),
    ),
  ),
)
```

### 9. **Location Map (Safe Zone)**

```dart
// Green overlay for safe zone
Container(
  decoration: BoxDecoration(
    color: AppColors.successGreen.withOpacity(0.1),
    border: Border.all(
      color: AppColors.successGreen,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Center(
    child: Text(
      'Safe Zone',
      style: TextStyle(
        color: AppColors.successGreen,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)

// Red overlay for danger zone
Container(
  decoration: BoxDecoration(
    color: AppColors.emergencyRed.withOpacity(0.1),
    border: Border.all(
      color: AppColors.emergencyRed,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Center(
    child: Text(
      'Danger Zone',
      style: TextStyle(
        color: AppColors.emergencyRed,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
```

### 10. **Gradients**

```dart
// Professional gradient background
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primaryDeepBlue.withOpacity(0.05),
        AppColors.primarySkyBlue.withOpacity(0.03),
      ],
    ),
  ),
  child: const Center(child: Text('Beautiful Background')),
)
```

---

## Colors by Feature

### 🔐 Authentication
- **Login/Register Buttons**: `AppColors.primaryDeepBlue`
- **Error Messages**: `AppColors.emergencyRed`
- **Help Text**: `AppColors.textMedium`

### 🚨 Emergency/SOS
- **SOS Button**: `AppColors.emergencyRed`
- **Emergency Alert**: `AppColors.emergencyRed`
- **Alert Text**: `AppColors.white` on Red background

### ✅ Verification/KYC
- **Verified Badge**: `AppColors.successGreen`
- **Approved Status**: `AppColors.successGreen`
- **Verification Progress**: `AppColors.primarySkyBlue`

### ⚠️ Warnings
- **Pending Review**: `AppColors.amberGold`
- **Warning Icon**: `AppColors.warningOrange`
- **Caution Message**: `AppColors.warningOrange`

### 📍 Location Tracking
- **Safe Zone**: `AppColors.successGreen`
- **Danger Zone**: `AppColors.emergencyRed`
- **Current Location**: `AppColors.primarySkyBlue`

---

## Implementation Checklist

- [ ] Create `app_colors.dart` ✅
- [ ] Update `main.dart` theme ✅
- [ ] Update Login Screen with `AppColors`
- [ ] Update Registration Screen
- [ ] Update Home Screen
- [ ] Update Tourist Dashboard
- [ ] Update Authority Dashboard
- [ ] Update Emergency Screens
- [ ] Update KYC Screens
- [ ] Test all screens for proper colors
- [ ] Verify dark mode compatibility

---

## Testing

Run your app to see all colors applied:
```bash
flutter run
```

All your screens should now have professional, real-world colors!

