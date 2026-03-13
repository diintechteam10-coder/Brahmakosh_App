# Technical Documentation: Ask BI (AI Rashmi) Feature

## 1. Executive Summary
**Ask BI** is the flagship AI conversational engine of Brahmakosh, offering a multi-persona (Krishna & Rashmi) experience. It supports hybrid interaction modes, including standard REST-based text chat and real-time WebSocket-based voice streaming.

---

## 2. Technical Stack & State Management
The feature utilizes **GetX** for high-performance state management and reactive dependency injection.

- **Controller**: `AiRashmiController` manages the chat lifecycle, message lists, and audio recording states.
- **Service Layer**: 
  - `AiRashmiService`: Handles stateless REST API interactions for chat creation, history, and messaging.
  - `VoiceWebSocketService`: Orchestrates the duplex WebSocket connection for low-latency voice streaming.

---

## 3. Conversational Engine (REST API)

| Feature | Method | Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **New Chat** | `POST` | `/api/mobile/chat` | Initializes a new thread with a dynamic title. |
| **History** | `GET` | `/api/mobile/chat` | Retrieves previous chat threads and metadata. |
| **Messages** | `GET` | `/api/mobile/chat/{chatId}` | Fetches message history for a specific thread. |
| **Messaging**| `POST` | `/api/mobile/chat/{chatId}/message` | Sends a user message and returns the AI reply. |

---

## 4. Voice Engine (WebSocket)

The voice interface implements a real-time streaming pipeline for a "Human-like" conversational experience.

### 4.1 Audio Processing Pipeline
1. **Recording**: Uses the `record` package to capture **16-bit PCM (Mono, 16kHz)** audio.
2. **Streaming**: Transmits base64-encoded PCM chunks every **150ms** via the `VoiceWebSocketService`.
3. **STT & TTS**: Integrates with **Deepgram** (transcription) and **ElevenLabs** (voice synthesis) on the backend.
4. **Playback**: Receives audio chunks from the server and plays them sequentially using `audioplayers` to ensure zero-gap audio.

### 4.2 Error Mitigation
- Handles specific voice-related errors (ElevenLabs API quota, unusual activity) with graceful fallbacks to text-only mode.
- Automatic cleanup of temporary audio files and WebSocket closure on session termination.

---

## 5. Deity Personas & UI
- **Persona Context**: Supports switching between **Krishna** (Spiritual Guide) and **Rashmi** (AI Companion).
- **Navigation Context**: Integrated directly into the Home Page and Gita feature via specialized banners and FABs.
- **UI Components**:
  - `DeitySelectionWidget`: Overlay for quick persona switching.
  - `Markdown` Support: All AI responses are rendered using `flutter_markdown` for rich text formatting and readability.

---

## 6. Directory Reference
- **Core View**: `lib/features/ai_rashmi/ai_rashmi_chat.dart`
- **State Controller**: `lib/features/ai_rashmi/ai_rashmi_view_model.dart`
- **API Services**: `lib/features/ai_rashmi/ai_rashmi_service.dart`
- **Voice Logic**: `lib/features/ai_rashmi/voice_websocket_service.dart`
