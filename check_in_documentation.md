# Developer Documentation: Brahmakosh Check-In Interface

## 1. Executive Summary
The Check-In module is a core spiritual engagement feature of the Brahmakosh application. It allows users to track their daily spiritual practices (Chanting, Prayer, Meditation, silence) and rewards them with "Karma Points." The interface is designed with a premium, minimalist aesthetic using dynamic gradients and micro-animations to create an immersive spiritual experience.

---

## 2. Technical Architecture

### 2.1 State Management
The module follows the **BLoC (Business Logic Component)** pattern for scalable and testable state management.
- **`CheckInBloc`**: Manages the main dashboard state and handles background pre-fetching of configurations.
- **`ChantingBloc` / `PrayerBloc`**: Handles specific activity configurations (emotion selection, mantra selection).
- **`MeditationSessionBloc`**: Manages the live playback session, timer sync, and final data submission.
- **`SpiritualStatsBloc`**: Handles the fetching and processing of historical data for visualization.

### 2.2 Navigation Logic
We utilize the **GetX (Get)** framework for lightweight, named-route navigation.
- **Route Management**: Centralized routes defined in `AppConstants`.
- **Arguments Handling**: Passing configuration data and pre-fetched JSON responses between screens to minimize network latency.

### 2.3 Repository & Data Layer
The **`SpiritualRepository`** serves as the single source of truth.
- **REST API Integration**: Uses a custom `callWebApi` abstraction for secure, token-based communication.
- **Isolate-based Parsing**: Heavy JSON decoding is offloaded to background isolates using Flutter’s `compute()` function to ensure 60fps UI performance.
- **Caching Layer**: Implements a write-through cache using `StorageService` to permit "offline-first" viewing of configurations.

---

## 3. Screen-by-Screen Implementation Details

### 3.1 Main Dashboard (`CheckInView`)
**Responsibility**: Entry point for all spiritual activities and quick summary of progress.
- **API Endpoints**:
    - **GET** `/api/mobile/content/spiritual-checkin`: Fetches activity categories, user stats summary, and recent activity list.
    - **GET** `/api/mobile/user/profile`: Fetches current user's profile image and details.
- **State Management**: `CheckInBloc`. On load, it fetches activity categories and user stats.
- **Key Implementation Details**:
    - **Stats Carousel**: Implemented using a `Timer.periodic` every 10 seconds. It toggles an index that drives an `AnimatedSwitcher` with a `SlideTransition`.
    - **Activity Grid**: Uses a `GridView.builder` with a fixed cross-axis count of 2 and `CachedNetworkImage` for efficiency.
    - **Pull-to-Refresh**: Wrapped in a `RefreshIndicator` that dispatches the `RefreshCheckIn` BLoC event.
- **Primary Widgets**: `CustomScrollView`, `SliverToBoxAdapter`, `AnimatedSwitcher`, `RefreshIndicator`.

---

### 3.2 Activity Configuration (`ChantingConfigurationView`)
**Responsibility**: Allows users to customize their spiritual session based on current mood.
- **API Endpoints**:
    - **GET** `/api/spiritual-configurations?categoryId={id}`: Fetches configurations (moods, mantras, durations) for the selected category.
- **State Management**: `ChantingBloc`. Manages emotion selection, mantra selection, and count adjustment.
- **Key Implementation Details**:
    - **Mood Selector**: A horizontal `ListView` with `AnimatedScale` and `ScrollController` auto-centering logic.
    - **Mantra Logic**: Dynamically filters available mantras from the pre-fetched configuration based on selected mood.
    - **Count Slider**: A custom-styled `Slider` using `SliderTheme` for पवित्र (sacred) count selection.
- **Primary Widgets**: `SliderTheme`, `_EmotionList`, `AnimatedScale`, `SingleChildScrollView`.

---

### 3.3 Session Playback (`MeditationStart`)
**Responsibility**: The core immersive experience for meditation or chanting.
- **API Endpoints**:
    - **GET** `/api/spiritual-clips/configuration/{configId}`: Fetches media clips (audio/video URLs) for the session.
    - **POST** `/api/spiritual-stats/save-session`: Submits duration, karma, and status to the server upon completion.
- **State Management**: `MeditationSessionBloc`. Handles lifecycle and result submission.
- **Key Implementation Details**:
    - **Dual Video Engine**: Cinematic transition from `Transition.mp4` to a looping `Meditation_video.mp4`.
    - **Audio Sync**: Managed via `AudioPlayer` with asset-based fallback and network streaming.
    - **Breathing Micro-animation**: `AnimationController` driven "pulse" effect synced with a digital breathing guide.
    - **Session Logic**: Tracks progress via `timerController`. Handles manual exits vs. full completion with status updates.
- **Primary Widgets**: `VideoPlayer`, `AudioPlayer`, `Stack`, `RepaintBoundary`.

---

### 3.4 Spiritual Statistics (`SpiritualStatsScreen`)
**Responsibility**: Historical data visualization and long-term progress tracking.
- **API Endpoints**:
    - **GET** `/api/spiritual-stats/user/{userId}`: Fetches detailed historical stats and activity breakdown.
    - **GET** `/api/mobile/user/profile`: Displays user identity and profile avatar.
- **State Management**: `SpiritualStatsBloc` combined with `ProfileViewModel`.
- **Key Implementation Details**:
    - **Data Visuals**: Employs `fl_chart` to render a `PieChart` mapping activities to distinct colors.
    - **Grid Stats**: Displays "Karma Points," "Minutes Spent," and "Sessions" using custom `_buildStatCard` widgets.
    - **History List**: A `ListView.separated` displays a detailed log of past activities with completion status.
- **Primary Widgets**: `PieChart`, `CircleAvatar`, `MultiProvider`, `BlocBuilder`.

---

## 4. Key Performance Optimizations
1. **Background Pre-fetching**: The `CheckInBloc` fetches upcoming screen data while the user is still on the main dashboard.
2. **Asset Management**: Uses `CachedNetworkImage` and managed media buffers to minimize latency.
3. **Repaint Boundaries**: Critical UI elements like charts and carousels are optimized for fluid rendering.

---

## 5. Development Dependencies
```yaml
dependencies:
  flutter_bloc: ^8.1.3      # Core state management
  get: ^4.6.5               # Navigation and Dialogs
  audioplayers: ^5.2.1      # Audio engine
  video_player: ^2.8.1      # Video engine
  fl_chart: ^0.63.0         # Data visualization
  cached_network_image: ^3.3.0 # Image optimization
  google_fonts: ^6.1.0      # Typography
```
