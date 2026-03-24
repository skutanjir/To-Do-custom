# PDBL Testing Custom Mobile: Enterprise Task Management with GPU Intelligence

## Executive Summary
PDBL Testing Custom Mobile (codenamed TEST_WUDI) is an enterprise productivity ecosystem built to bridge high-performance task management with local artificial intelligence. Built on the Flutter framework and powered by a dual-stack backend (Laravel and a Python GPU Sidecar), the application delivers a fast, offline-first experience with advanced semantic reasoning capabilities optimized for Nvidia RTX hardware.

## Core Technology Stack

| Layer | Technology | Key Implementation |
|-------|------------|--------------------|
| Frontend | Flutter / Dart | RepaintBoundary isolation, custom glassmorphism |
| Database | Isar 3.1.0+1 | NoSQL, offline-first, full-text search |
| API Layer | Dio | Auth interceptors, session continuity |
| AI Logic | PHP 8.3 | Custom 19-expert reasoning engine |
| AI Compute | Python / FastAPI | RTX GPU bridging, CUDA 13.0 |
| Backend | Laravel 11 | Sanctum auth, PostgreSQL persistence |

## Architecture Overview

### High-Level System Architecture
The platform operates on a tri-layer architecture designed for maximum resilience and speed. The Flutter client handles immediate user interactions and local persistence. The Laravel backend acts as the central source of truth for synchronization and identity management. The Python sidecar provides specialized neural processing for complex semantic queries that require GPU acceleration.

### Flutter and State Management Architecture
The frontend architecture prioritizes frame consistency and low memory overhead over heavy external dependencies.

*   **State Management**: The application uses native Flutter reactive mechanisms (such as `ChangeNotifier` and `ValueNotifier`) combined with Isar database streams. This approach eliminates the overhead of third-party state management libraries. The UI subscribes directly to database queries, ensuring that changes to the local Isar database instantly reflect on the screen without manual state orchestration.
*   **Optimistic UI Updates**: State mutations occur locally first. When a user creates or modifies a task, the UI updates immediately. Network synchronization happens asynchronously in the background. If a network request fails, the local state retains the operation for a future retry.
*   **UI Thread Preservation**: To prevent frame drops during intensive operations, complex animations and list views are isolated using `RepaintBoundary`. AI text streaming uses a 50ms buffer to prevent the main UI thread from locking up during rapid text generation.

### Neural Dispatcher (Jarvis Engine)
The local AI engine processes user input through a multi-stage pipeline:
1.  **Linguistic Normalization**: Filters noise and detects the input language (Indonesian, English, Javanese, Sundanese, Betawi).
2.  **Intent Scoring**: A semantic algorithm ranks over 40 potential intents to understand the user's goal.
3.  **GPU Synthesis**: High-complexity search queries are sent to the Python sidecar for vector similarity calculation.
4.  **Chain-of-Thought Processing**: Analytical queries generate a logical reasoning trace exposed directly to the UI.

### Offline-First Data Strategy
The application implements a fast synchronization protocol:
*   **Conflict Resolution**: Local changes are tracked via Isar. The task repository ensures O(1) efficiency during server parity checks.
*   **Guest-to-User Migration**: Local data associated with a device ID merges automatically into a user account upon the first authentication.

## Installation and Environment Configuration

### Prerequisite Checklist
*   Flutter SDK: Version 3.10.0 or later
*   Python: Version 3.10 or later (required for GPU acceleration)
*   CUDA Toolkit: Version 12.0 or higher (for Nvidia RTX support)
*   Backend: A running instance of the PDBL-BACKEND
*   Hardware: Minimum 4GB VRAM recommended for GPU-accelerated semantic search

### Mobile Setup Instructions
Follow these steps to configure and run the Flutter application.

1.  **Repository Acquisition**
    Clone the repository and enter the project directory:
    ```bash
    git clone https://github.com/skutanjir/To-Do-custom.git
    cd To-Do-custom
    ```

2.  **Dependency Installation**
    Fetch all required Dart packages:
    ```bash
    flutter pub get
    ```

3.  **Code Generation**
    Generate the Isar database schemas and boilerplate code. This step is required before building the app:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Environment Configuration**
    Create a `.env` file in the root directory. The application requires this file for API communication:
    ```text
    API_URL=http://[YOUR_SERVER_IP]/api
    ```

5.  **Run the Application**
    Start the app on an attached device or emulator:
    ```bash
    flutter run
    ```

### Configuring the GPU Accelerator (Optional)
The Jarvis v13.0 "Nebula" mode requires the Python sidecar to be active.

1.  **Install Python Dependencies**
    Ensure your Python environment has the necessary neural processing libraries:
    ```bash
    pip install torch sentence-transformers fastapi uvicorn pydantic
    ```

2.  **Start the Service**
    Launch the sidecar from the backend directory:
    ```bash
    python gpu_sidecar.py
    ```
    The mobile app will detect the service at `http://127.0.0.1:8080`. If successful, a GPU status indicator will appear in the Jarvis interface.

## Performance Engineering Details

*   **Database Optimization**: The `todos` table uses composite indices on `(user_id, is_completed)` and `(team_id)`. This guarantees sub-millisecond query times even on large datasets.
*   **Batch Processing**: All server synchronization operations use `putAll()` transactions in Isar to reduce I/O overhead.
*   **Glassmorphism Capping**: Backdrop blurs are restricted to a maximum sigma of 10 to balance aesthetics with GPU fill-rate limits.

## Security and Data Integrity Standards

*   **Authentication Protocol**: Every AI and Task endpoint is secured via `auth:sanctum` middleware. The backend uses a dual-identifier strategy (Bearer Token plus X-Device-ID) to maintain session continuity during network transitions.
*   **Domain Firewall**: The Jarvis AI features a domain guard that filters queries. Any prompt attempting to bypass the productivity context (such as illegal queries or prompt injection) is terminated by the internal classifier before execution.

## Deployment Procedures

### Android Release
Generate an architecture-specific APK for distribution:
```bash
flutter build apk --target-platform android-arm64 --release
```
To generate an App Bundle for the Google Play Store:
```bash
flutter build appbundle --release
```

### iOS Deployment
Ensure CocoaPods are updated before building via Xcode:
```bash
cd ios
pod install
cd ..
flutter build ios --release
```

## Contributing Guidelines

We welcome contributions from the engineering community. To maintain codebase quality, please adhere to the following workflow:

1.  **Fork and Branch**: Create a feature branch from `main` (`feature/issue-number-description`).
2.  **Code Standards**: Write clean, self-documenting code. Do not introduce new external state management libraries. Rely on the existing native reactive architecture.
3.  **Testing**: Ensure all new features include corresponding widget or unit tests.
4.  **Pull Request**: Submit a detailed PR explaining the problem, your solution, and any architectural trade-offs. Assign at least one core maintainer for review.

## License and Terms of Use
This project is proprietary and confidential. Unauthorized copying, modification, or distribution of these files is strictly prohibited unless authorized under the MIT License terms provided in the LICENSE file.