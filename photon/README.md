# Photon: High-Speed File Sharing App

Photon is a high-performance, cross-platform file-sharing application built with Flutter. It prioritizes raw transfer speed using low-level `dart:io` Sockets and maintains a fluid 60FPS user interface by offloading heavy I/O operations to background Isolates.

| Feature | Description |
| :--- | :--- |
| **Zero-Data Transfer** | Uses Wi-Fi Direct / Local Hotspot (Offline). |
| **High Performance** | 64KB Chunking strategy + Background Isolates. |
| **Slick UI** | 60FPS Animations using `flutter_animate` and custom Painters. |
| **Dark Theme** | Premium aesthetic with `GoogleFonts.outfit`. |

---

## 🏗 Architecture

### 1. Concurrency Model
To ensure the main UI thread never stutters, Photon uses a strict **Isolate** separation:
*   **Main Isolate**: Handles UI rendering, user input, and animations.
*   **Transfer Isolate (Worker)**: Handles File I/O (Read/Write) and Socket streaming.

Communication happens via specific **Command/State** messages passed through `SendPort` and `ReceivePort`.

### 2. Protocol
*   **Transport**: TCP Sockets.
*   **Buffer**: 64KB (65536 bytes) chunks to optimize for CPU L1/L2 cache and avoid GC pressure.
*   **Flow Control**: Simple backpressure handling to prevent memory OOM on large files.

---

## 🚀 Setup & Run

### Prerequisites
*   Flutter SDK (3.27.0 or higher recommended)
*   Dart SDK

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/your-repo/photon.git
    cd photon
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```
    *   *Note*: For transferring files, you currently need two generic devices or use the Mock IP `127.0.0.1` for testing the flow on a single device.

---

## 🛠 Development Log & Troubleshooting

During the initial MVP build, several challenges and errors were encountered. Below is a log of these issues and their solutions, serving as a guide for future contributors.

### 1. Shell Command Syntax (Windows PowerShell)
*   **Error**: `mkdir : A positional parameter cannot be found that accepts argument 'lib/core/models'.`
*   **Cause**: The command `mkdir -p a b c` is valid in Bash but fails in PowerShell, which treats commas or distinct arguments differently for `New-Item`.
*   **Solution**: Used a comma-separated list or separate commands: `mkdir lib/core/transfer, lib/core/models`.

### 2. Typo in Imports
*   **Error**: `Target of URI doesn't exist: 'dart:isotope'.`
*   **Cause**: A typo when manually creating the `transfer_models.dart` file.
*   **Solution**: Corrected import to **`dart:isolate`** (or removed it as it wasn't strictly needed for the model class itself).

### 3. Missing Method in `TransferScreen`
*   **Error**: `The method '_pickAndSend' isn't defined for the type '_TransferScreenState'.`
*   **Cause**: An automated refactoring tool (LLM) accidentally truncated the file or pasted the method `_pickAndSend` *outside* the class closing brace `}` during an edit.
*   **Solution**: Restored the method signature and ensured it was placed correctly inside the `State` class.

### 4. Async Context Safety
*   **Warning**: `Don't use 'BuildContext's across async gaps.`
*   **Cause**: referencing `context` (e.g., `ScaffoldMessenger.of(context)`) after an `await` call (like `FilePicker.platform.pickFiles`). If the widget is unmounted (user left the screen), this crashes.
*   **Solution**: Added `if (!context.mounted) return;` checks after every `await` call before using `context`.

### 5. Deprecated Flutter APIs
*   **Warning (Opacity)**: `'withOpacity' is deprecated and shouldn't be used.`
*   **Solution**: Migrated to the new `Color.withValues(alpha: 0.5)` API which avoids precision loss associated with the old opacity method.
    ```dart
    // Old
    color.withOpacity(0.2)
    // New
    color.withValues(alpha: 0.2)
    ```
*   **Warning (Material3)**: `'useMaterial3' is deprecated.`
*   **Solution**: Removed `useMaterial3: true` from `ThemeData`. It is now the default behavior in modern Flutter versions.

### 6. Permission Handling
*   **Issue**: `FilePicker` fails or returns nothing without permissions on Android.
*   **Solution**: Integrated `permission_handler`.
    ```dart
    if (await Permission.storage.request().isGranted) { ... }
    ```
    *Note*: For Android 13+, granular permissions (`photos`, `videos`) are technically required, but `storage` covers legacy devices for this MVP.

---

## 📦 Project Structure

```
lib/
├── core/
│   ├── models/            # Data classes (TransferState, TransferCommand)
│   └── transfer/
│       ├── transfer_isolate.dart  # Background Worker
│       └── transfer_manager.dart  # Logic Controller
├── ui/
│   ├── screens/
│   │   ├── home_screen.dart       # Main Menu
│   │   └── transfer_screen.dart   # Progress & States
│   ├── theme/
│   └── widgets/
│       └── ripple_animation.dart  # CustomPainter Radar
└── main.dart              # Entry Point
```
