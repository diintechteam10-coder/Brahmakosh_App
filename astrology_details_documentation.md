# Technical Deep-Dive: Personal Astrology Details Engine

## 1. Feature Architecture
The Personal Astrology module (`AstrologyDetailsScreen`) is the analytical core of the Brahmakosh app. It processes thousands of points of astronomical data to render a 9-tabbed interface covering every aspect of a user's Vedic horoscope.

### 11.1 Master Data Orchestration
- **Source**: `UserCompleteDetailsModel` (fetched from `getUserCompleteDetails` API).
- **Caching**: Implements a `astrology_data_{userId}` local storage key for instantaneous subsequent loads.
- **State**: Managed via a `StatefulWidget` using a `TabController` with a length of 9.

---

## 2. Comprehensive Tab Breakdown

### 2.1 Basic Information & Vedic Markers
- **Technical Metrics**: 
  - **Ayanamsha**: Supports multiple calculation systems (Lahiri, Raman, etc.) with degree and formatted offsets.
  - **Ghat Chakra**: Monitors variable astrological markers like `Month`, `Tithi`, `Pahar`, and `Nakshatra`.
- **Identity Markers**: Displays personal markers such as `Yunja`, `Tatva`, `Paya`, and `Name Alphabet` based on the birth chart.

### 2.2 Planetary Positions (Standard & Extended)
- **Visualization**: Maps all 9 planets to their respective `Sign`, `House`, and `Nakshatra`.
- **Navigation**: Deep links to `PlanetPositionsScreen` which utilizes a `TabController` to toggle between **Standard** and **Extended** planetary positions.
- **Detail View**: Tapping a planet navigates to `PlanetDetailScreen` for longitudinal analysis.

### 2.3 Interactive Charting Engine
- **Chart Logic**: Powered by the `NorthIndianChart` widget.
- **Lagna vs. Navamsa**: Users can toggle between the **Birth Chart (D1)** and **Birth Extended Chart (D9)**.
- **Bhav Chalit**: A technical table showing **Bhav Madhya** (House Center) and **Bhav Sandhi** (House Boundaries) with precision DMS (Degree-Minute-Second) formatting.

### 2.4 Dosha Analytical Engine
The `DoshasTab` navigates to `DoshaDetailScreen` for deep textual analysis:
- **Manglik Dosha**: Detailed reporting on presence rules (Aspect vs. House) and logic-based cancellation rules.
- **Kalsarpa Dosha**: Provides a presence analysis and one-line summaries.
- **Pitra Dosha**: Sub-screen covering conclusions, rules matched, effects, and customized remedies.
- **Sade Sati (Saturn Transit)**:
  - **Current Status**: Identifies if the user is undergoing the 7.5-year cycle.
  - **Life Cycle Timeline**: A visual timeline in `DoshaDetailScreen` mapping **Rising (Orange)**, **Peak (Red)**, and **Setting (Green)** phases across the user's entire lifespan.

### 2.5 Dynamic Dasha Timelines
Manages the temporal aspect of Vedic astrology through a 3-tab sub-view (`AllDashasScreen`):
- **Vimshottari Dasha**: A 5-level deep hierarchy (Mahadasha, Antardasha, Pratyantar, Sukshma, Prana) with active period highlighting.
- **Yogini & Chardasha**: Real-time status dashboards for secondary planetary period systems.
- **Technical Merging**: The `_getEffectiveDashas()` method merges top-level and embedded API fields to ensure data integrity across different backend response versions.

### 2.6 Point Systems (Ashtakvarga & Sarvashtak)
Interactive technical tabs for quantitative analysis:
- **Sarvashtakvarga**: 
  - **Table View**: Sign-wise total points (Aries-Pisces) across 8 factors.
  - **Point Chart**: A North Indian chart visualization highlighting houses with >28 points (marked in green) for auspiciousness.
- **Ashtakvarga (Planet-wise)**: Dropdown-based analysis for individual planets, toggling between House Charts and Factor Tables.

---

## 3. Remedies & Prescription Engine
- **Gemstone Suggestions**: Technical logic parsing `gemstoneSuggestion` from the API.
- **Integrated Remedies**: Combines Dosha-specific remedies with general remedial measures like Mantras, Charity, and Rituals into a consolidated `RemediesTab`.

---

## 4. Navigation & Directory Reference
- **Main Engine**: `lib/features/home/views/astrology_details_screen.dart`
- **Sub-Screens**: 
  - `lib/features/home/views/dosha_detail_screen.dart`
  - `lib/features/home/views/all_dashas_screen.dart`
  - `lib/features/home/views/planet_positions_screen.dart`
- **Widgets**: `lib/features/home/widgets/` (Charts, Tickers, and Tab Layouts)
- **API Model**: `lib/common/models/user_complete_details_model.dart`
- **API Service**: `getUserCompleteDetails` in `lib/common/api_services.dart`
