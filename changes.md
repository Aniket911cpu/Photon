# Development Changes & Troubleshooting Log (Complete)

## 1. PowerShell Command Syntax Error
**Problem:** `mkdir` command failures in Windows PowerShell.
**Solution:** Used comma-separated paths or separate commands.

## 2. Typo in Dart Import
**Problem:** `dart:isotope` typo.
**Solution:** Fixed to `dart:isolate`.

## 3. Missing Method Definition (`_pickAndSend`)
**Problem:** Method logic missing in `TransferScreen` after refactor.
**Solution:** Manually restored method.

## 4. Async Context Use
**Problem:** `Use of BuildContext across async gaps` lint.
**Solution:** Added `if (!context.mounted) return;` checks.

## 5. Deprecated APIs
**Problem:** `withOpacity` and `useMaterial3`.
**Solution:** Replaced with `withValues(alpha:)` and removed `useMaterial3: true`.

## 6. Import Errors (Module 2)
**Problem:** Relative imports broken between `screens` and `tabs` folders.
**Solution:** Fixed relative paths to `../tabs/`.

## 7. Const Constructor Constraints
**Problem:** `const` list containing non-const widgets in `TabBarView`.
**Solution:** Removed `const` keyword.

## 8. Async Handlers in Home Screen
**Problem:** `await` used in synchronous `onTap` closure.
**Solution:** Added `async` keyword to the closure: `onTap: () async { ... }`.
