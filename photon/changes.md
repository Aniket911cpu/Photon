# Development Changes & Troubleshooting Log

This document records the specific technical issues encountered during the initial development of the Photon MVP and the solutions applied to resolve them.

## 1. PowerShell Command Syntax Error
**Problem:**  
The command `mkdir -p lib/core/transfer lib/core/models ...` failed in Windows PowerShell.
*   *Error Message*: `A positional parameter cannot be found that accepts argument 'lib/core/models'.`
*   *Context*: PowerShell's `mkdir` (alias for `New-Item`) does not support the `-p` flag in the same way as Bash, and handling multiple path arguments often requires comma separation or explicit array passing.

**Solution:**  
Refactored the command to use comma-separated values which is idiomatic for PowerShell:
```powershell
mkdir lib/core/transfer, lib/core/models, lib/ui/screens, ...
```

## 2. Typo in Dart Import
**Problem:**  
A typo was introduced in `lib/core/models/transfer_models.dart`.
*   *Error Message*: `Target of URI doesn't exist: 'dart:isotope'.`
*   *Context*: Misspelling of the standard library `dart:isolate`.

**Solution:**  
Corrected the import statement to:
```dart
import 'dart:isolate';
```
*(Note: It was later determined that this import wasn't strictly necessary for the model definitions, but the typo was fixed nonetheless.)*

## 3. Missing Method Definition (`_pickAndSend`)
**Problem:**  
The `TransferScreen` widget failed to analyze because the `_pickAndSend` method was called but not defined in the class body.
*   *Error Message*: `The method '_pickAndSend' isn't defined for the type '_TransferScreenState'.`
*   *Context*: Likely caused by an automated code generation or refactoring step that truncated the file or misplaced the closing brace.

**Solution:**  
Manually restored the missing method signature and implementation inside the `_TransferScreenState` class:
```dart
Future<void> _pickAndSend(BuildContext context) async {
  // Logic for permission check and file picking
}
```

## 4. Async Context Use (`use_build_context_synchronously`)
**Problem:**  
Lint warnings were raised for using `context` after asynchronous operations.
*   *Warning*: `Don't use 'BuildContext's across async gaps.`
*   *Context*: Calling `ScaffoldMessenger.of(context)` or accessing `Provider` after `await FilePicker.platform.pickFiles()`. If the user backs out of the screen during the file pick, utilizing `context` would cause a crash.

**Solution:**  
Added "mounted" checks after every `await`:
```dart
if (await _requestPermissions()) {
  if (!context.mounted) return; // <--- ADDED
  FilePickerResult? result = await FilePicker.platform.pickFiles(...);
  
  if (result != null && context.mounted) { // <--- ADDED
     // Use context
  }
}
```

## 5. Deprecated API: `withOpacity`
**Problem:**  
The `withOpacity` method on `Color` is deprecated in newer Flutter versions to avoid loss of precision (Color is now 64-bit).
*   *Warning*: `'withOpacity' is deprecated and shouldn't be used.`

**Solution:**  
Migrated all instances to `Color.withValues`:
```dart
// Before
color.withOpacity(0.2)

// After
color.withValues(alpha: 0.2)
```

## 6. Deprecated API: `useMaterial3`
**Problem:**  
Explicitly setting `useMaterial3: true` in `ThemeData` is now deprecated as it is the default behavior.
*   *Warning*: `'useMaterial3' is deprecated...`

**Solution:**  
Removed the line `useMaterial3: true` from the `_buildTheme` method in `main.dart`.

## 7. Unused Imports
**Problem:**  
Several files had unused imports (e.g., `dart:math`, `provider`).
*   *Warning*: `Unused import`.

**Solution:**  
Ran cleanup to remove all unused import lines to keep the code clean and minimize bundle size.
