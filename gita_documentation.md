# technical Documentation: Bhagavad Gita Feature

## 1. Architecture Overview
The Bhagavad Gita module is architected using the **BLoC (Business Logic Component)** pattern, ensuring a strict separation between UI, state management, and the data layer. It provides a seamless hierarchical experience from chapter discovery to deep shloka analysis.

### 1.1 Core Components
- **Repository**: `GitaRepository` acts as the single source of truth, orchestrating both API calls and local cache retrieval.
- **State Management**:
  - `GitaChapterBloc`: Manages the discovery and listing of the 18 chapters.
  - `GitaVerseBloc`: Handles the enumeration of shlokas within a specific chapter.
  - `GitaDetailBloc`: Provides deep insights, translations, and explanations for individual verses.

---

## 2. API Data Architecture

The feature integrates with three distinct REST endpoints to minimize data transfer and optimize loading performance.

| Endpoint Purpose | HTTP Method | URL Structure | Technical Note |
| :--- | :--- | :--- | :--- |
| **List Chapters** | `GET` | `/api/chapters` | Returns chapter metadata and shloka counts. |
| **List Verses** | `GET` | `/api/shlokas/chapter/{chNumber}` | Fetches verse indices for a specific chapter. |
| **Shloka Detail** | `GET` | `/api/shlokas/{verseId}` | Returns full Sanskrit shloka, transliteration, and meanings. |

---

## 3. Persistent Caching Strategy (`StorageService`)

To ensure a "Smooth Load" experience, the application implements a multi-level caching system that prioritizes local storage over network requests.

- **Level 1 (Chapters)**: Cached under `gita_chapters_cache`. Synchronized on every app launch if network is available.
- **Level 2 (Verse Lists)**: Cached per chapter using the prefix `gita_verses_chapter_`. This prevents re-fetching shloka indices for already explored chapters.
- **Level 3 (Verse Details)**: Individual verses are cached using the ID-specific key `gita_verse_{verseId}`, allowing instant access to previously read shlokas.

---

## 4. User Experience Logic

- **"Last Read" Persistence**: The app tracks the user's progress using `gita_last_chapter_number` and `gita_last_verse_number` in `StorageService`. A "Continue" banner is dynamically generated on the main Gita screen for quick resume.
- **Progress Tracking**: Each chapter card visualizes reading progress (e.g., `3/72 Verses`) based on locally stored reading history.
- **"Ask Krishna" Integration**: A specialized Floating Action Button (FAB) provides a direct bridge to the **AI Rashmi** feature, maintaining the "Krishna" persona context for spiritual queries.

---

## 5. Directory Reference
- **Views**: `lib/features/gita/views/`
- **Business Logic**: `lib/features/gita/bloc/`
- **Data Layer**: `lib/features/gita/data/`
- **Models**: `ChapterModel`, `VerseModel`
