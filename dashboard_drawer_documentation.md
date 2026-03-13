# Developer Documentation: Dashboard & Drawer Navigation Hub

## 1. Executive Summary
The navigation architecture of Brahmakosh is built around a centralized `DashboardView` which serves as the primary container for the "Spiritual Operating System." It utilizes a persistent Bottom Navigation Bar for core feature access and a detailed Sidebar Drawer for personal profile management, financial wallets, and administrative settings.

---

## 2. Dashboard Engine (`DashboardView` & `DashboardViewModel`)

The Dashboard manages the lifecycle of the primary application tabs, ensuring state persistence and optimized screen transitions.

### 2.1 Navigation Orchestration
- **Controller**: `DashboardViewModel` (utilizing `ChangeNotifier`) manages the `currentIndex`.
- **View Container**: `IndexedStack` is used within the `DashboardLayout` to keep the state of all tabs alive, preventing redundant re-builds during tab switching.
- **Dynamic Tab Behavior**: The `CustomBottomNavBar` is programmatically hidden when navigating to full-screen interactive views like **Rashmi AI Chat** (Index 2) or **Remedies WebView** (Index 4).

### 2.2 Core Screen Mapping (Bottom Tabs)
| Tab Index | Feature | Screen Component | Technical Note |
| :--- | :--- | :--- | :--- |
| **0** | **Home Hub** | `HomeView` | Features scroll-to-top logic on re-selection. |
| **1** | **Check-In** | `CheckInView` | Centralized spiritual session manager. |
| **2** | **Rashmi AI** | `RashmiAi` / `RashmiChat` | Direct transition to specialized AI agent chat interface. |
| **3** | **Connect** | `AstrologyExpertsView` | The marketplace for expert consultation. |
| **4** | **Remedies** | `RemediesWebView` | Dynamically loaded to optimize memory usage. |

---

## 3. App Drawer Ecosystem (`AppDrawer`)

The Sidebar Drawer serves as the "Administrative Center" for the user, providing deep access to profile, financial, and ecosystem-wide services.

### 3.1 Profile & Identity Management
- **Visuals**: Dynamic `NetworkImage` profile header with Hero animation support.
- **Actions**: Direct navigation to `ProfileDetailsView` and `UpdateProfileView`.
- **State Source**: Consumes `ProfileViewModel` for real-time name, contact, and email sync.

### 3.2 Financial & Rewards Infrastructure
- **Karma Wallet**: Visualizes `karmaPoints` with a direct navigation route to the **Redeem** flow (`AppConstants.routeRedeem`).
- **Credit Wallet**: Visualizes `credits` with a direct link to `RechargePlansView` for adding funds.
- **Audit Trails**: Link to `CreditHistoryView` to track all financial transactions.

### 3.3 Extended Navigation Flow
- **My Kosh**: Navigates to `ReportView` (Index 5 of the Dashboard stack).
- **Avatar Agent**: Specialized entry point to `AvatarAgentPage` for advanced AI interaction.
- **Account Maintenance**: 
  - **Language**: Toggle mechanism between English (En) and Hindi (Hi).
  - **Logout**: Secure session termination logic via `StorageService` (clearing auth token and user ID).

---

## 4. API Integration & Data Architecture

The Dashboard and Drawer components act as the primary interface for user state and environmental context, powered by the following backend services:

### 4.1 User Profile & Wallets
- **Fetch/Update Profile**: `GET/PUT /api/mobile/user/profile`
    - Returns comprehensive user data including `credits`, `karmaPoints`, and basic bio.
- **Image Upload**: `POST /api/mobile/user/profile/image` (Multipart)
    - Replaces the `profile_image` asset on the server.

### 4.2 Geo-Intelligence Engine
- **Location Sync**: `POST /api/mobile/user/get-location`
    - Sends `latitude` and `longitude` to the server to update user context.
- **Reverse Geocoding**: `POST /api/mobile/user/reverse-geocode`
    - Converts coordinates into a human-readable `city` and `state` for localized UI greetings.

### 4.3 Financial Services
- **Credit History**: `GET /api/chat/credits/history/user`
    - Fetches the audit trail for wallet transactions displayed in `CreditHistoryView`.
- **Reward Redemption**: `POST /api/reward-redemptions/redeem`
    - Triggered from the Karma Wallet's "Redeem" flow.

---

## 5. Architectural State Logic

### 4.1 Location Intelligence
The `DashboardViewModel` manages background location tracking:
- **`initLocationUpdate`**: Triggered on build and app-foregrounding (`resumed` lifecycle state).
- **Reverse Geocoding**: Fetches city/state data from the server and caches it in `StorageService` under `keyUserLocation` for dashboard personalization.

### 4.2 Scroll Synchronization
The `DashboardLayout` maintains individual `ScrollController` instances for Home, Check-In, and Connect tabs, enabling a "Jump to Top" feature when a user taps an already active tab.

---

## 5. Directory Reference
- **Dashboard View**: `lib/features/dashboard/views/dashboard_view.dart`
- **Navigation State**: `lib/features/dashboard/viewmodels/dashboard_viewmodel.dart`
- **Sidebar Drawer**: `lib/features/dashboard/widgets/app_drawer.dart`
- **Bottom Bar**: `lib/features/dashboard/widgets/custom_bottom_nav_bar.dart`
