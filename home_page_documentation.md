# Developer Documentation: Brahmakosh Home Ecosystem (Spiritual OS)

## 1. Executive Summary
The Home Ecosystem is a sophisticated "Spiritual Operating System" designed to provide real-time Vedic intelligence. Beyond the central dashboard, it encompasses a network of specialized detail screens for Panchang data, planetary positioning, and deep astrological analysis. This ecosystem utilizes GetX state management, parallel API orchestration, and persistent caching to deliver a responsive, content-rich experience.

## 2. Global Navigation Shell (`DashboardView`)
The `DashboardView` acts as the persistent container for the primary application features, managing the lifecycle of each module through a unified state.

### 2.1 Tab Orchestration
- **Mechanism**: Utilizes `IndexedStack` to preserve the state of different screens when switching tabs.
- **Primary Tabs**:
  - **Home** (Index 0): The main hub for Vedic insights.
  - **Check-In** (Index 1): Holistic wellbeing and meditation sessions.
  - **AI Chat** (Index 2): Interactive AI agent (Rashmi).
  - **Connect** (Index 3): Professional astrology expert consultations.
  - **Remedies** (Index 4): Web-based remedial measure catalog.
- **State Management**: `DashboardViewModel` handles tab indices and provides navigation commands.

### 2.2 Global Navigation Drawer (`AppDrawer`)
The Drawer provides a high-level entry point for accounts, settings, and secondary features.

| Category | Features Included | Technical Detail |
| :--- | :--- | :--- |
| **User Profile** | Name, Email, Profile Image | Fetches from `ProfileViewModel`. Supports real-time image updates. |
| **Wallets** | Karma Wallet & Credit Wallet | Displays real-time points with navigation to "Redeem" or "Recharge". |
| **Feature Menu** | My Kosh, Orders, Credit History, Avatar Agent | Direct navigation to specialized reporting and management screens. |
| **System** | Settings, Support, About Us | Entry points for application maintenance and knowledge. |
| **Utilities** | Change Language (En/Hi) | Persistent localization switch. |
| **Security** | Logout | Dynamic session clearing and redirection to Login. |

---

## 3. Main Dashboard (`HomeView`)

### 3.1 Technical Orchestration
- **Controller**: `HomeController` (GetX) initializes the ecosystem by loading local caches and then refreshing global state.
- **Parallel Refresh**: `refreshHomeData()` utilizes `Future.wait` to concurrently fetch:
  - `UserCompleteDetails`
  - `PanchangData`
  - `Remedies`
  - `Dosha/Dasha`
  - `Sponsors`
  - `FounderMessages`

### 2.2 Dynamic UI Components
- **`HomeTopBar`**: A context-aware header that adjusts backgrounds (Morning/Day/Night) and personal greetings based on system clock and user profile.
- **Engagement Modules**: `LuckInFavourSection` manages interactive animations for "Lucky Flip" and "Scratch Card" rewards.

---

## 3. Vedic Calendar Deep-Dive (`PanchangDetailsView`)

The Panchang view provides a granular breakdown of the Vedic day, mapping real-time astronomical data to spiritual relevance.

### 3.1 Data Architecture
- **API Endpoint**: `{{baseUrl}}/api/client/users/{userId}/panchang`
- **Models**: `BasicPanchang`, `AdvancedPanchang`, `ChaughadiyaMuhurta`.

### 3.2 Feature Layers
| Section | Implementation Detail |
| :--- | :--- |
| **Hindu Calendar** | Displays Vikram/Shaka Samvat, Amanta/Purnimanta months, and current Ritu/Ayana. |
| **Panchang Timelines** | Charts the start/end times for Tithi, Nakshatra, Yog, and Karan. |
| **Auspicious Muhurats** | Highlights **Abhijit Muhurta** as the primary positive window. |
| **Kaal Analysis** | Tracks inauspicious windows: **Rahu Kaal**, **Guli Kaal**, and **Yamghant Kaal**. |
| **Chaughadiya** | Provides a list of Day and Night Muhurtas with color-coded "Good/Bad/Avg" indicators. |

---

## 4. Personal Astrology Details Engine (`AstrologyDetailsScreen`)

### 4.1 Feature Architecture
The Personal Astrology module is the analytical core of the app, processing thousands of astronomical data points through 9 specialized tabs.
- **Master Data**: Consumes `UserCompleteDetailsModel` with `astrology_data_{userId}` local persistence.
- **State**: Managed via a `StatefulWidget` using a `TabController`.

### 4.2 Comprehensive Tab Breakdown
#### A. Basic Info & Vedic Markers
- **Technical Metrics**: Supports multiple **Ayanamsha** systems and monitors **Ghat Chakra** variables (Tithi, Pahar, etc.).
- **Identity Markers**: Displays personal markers like `Yunja`, `Tatva`, and `Paya`.

#### B. Planetary Positions
- **Dual Layer**: Maps all 9 planets across **Standard** and **Extended** datasets.
- **Navigation**: Deep links to `PlanetPositionsScreen` for longitudinal analysis and individual planet details.

#### C. Interactive Charting
- **Engine**: Powered by `NorthIndianChart`.
- **D1 vs D9**: Real-time toggling between **Lagna** and **Navamsa** charts.
- **Bhav Chalit**: Technical tables for **Bhav Madhya** and **Bhav Sandhi** with DMS precision.

#### D. Dosha Analytical Engine
- **Manglik/Kalsarpa**: Rule-based detection (Aspect vs House) and cancellation logic.
- **Pitra Dosha**: Conclusion reporting with specific effects and remedies.
- **Sade Sati Timeline**: A visual timeline mapping **Rising (Orange)**, **Peak (Red)**, and **Setting (Green)** phases across the user lifespan.

#### E. Dynamic Dasha Timelines
- **Vimshottari**: 5-level deep hierarchy (Mahadasha to Prana) with active period highlighting.
- **Yogini & Chardasha**: Real-time status dashboards for secondary systems.
- **Data Merging**: `_getEffectiveDashas()` logic ensures consistent rendering across backend versions.

#### F. Point Systems (Ashtakvarga & Sarvashtak)
Interactive technical tabs for quantitative analysis:
- **Sarvashtakvarga**: 
  - **Table View**: Sign-wise total points (Aries-Pisces) across 8 factors (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Ascendant).
  - **Point Chart**: A **North Indian Point Chart** visualization highlighting houses with **>28 points** (marked in green) as highly auspicious indicators.
- **Ashtakvarga (Planet-wise)**: Dropdown-based analysis for individual planets (Sun to Saturn), toggling between **House Charts** and **Factor Detail Tables**.
- **Visual Feedback**: Uses `AnimatedCrossFade` for seamless switching between technical tables and spiritual charts.

---

## 5. Implementation Best Practices
1. **Hybrid Data Merging**: Centralized logic for timeline rendering regardless of API response versioning.
2. **Dynamic UI Modularity**: `TabBarView` and `AnimatedCrossFade` ensure a high-performance, fluid user experience.
3. **Location Sensitivity**: Real-time syncing of astronomical data with user's geolocation for precise Vedic accuracy.

---

## 6. Directory Reference
- **Dashboard**: `lib/features/home/views/home_view.dart`
- **Panchang Engine**: `lib/features/home/views/panchang_details_view.dart`
- **Astrology Engine**: `lib/features/home/views/astrology_details_screen.dart`
- **Sub-Screens**: 
  - `lib/features/home/views/dosha_detail_screen.dart`
  - `lib/features/home/views/all_dashas_screen.dart`
  - `lib/features/home/views/planet_positions_screen.dart`
- **Widgets System**: `lib/features/home/widgets/` (Charts, Tickers, and Tab Layouts)
- **API Model**: `lib/common/models/user_complete_details_model.dart`
