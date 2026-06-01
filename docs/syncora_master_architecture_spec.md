# Syncora AI: Master Architecture & Product Requirements Specification (SRS)

## 1. Intent & Product Vision
Syncora AI is a cross-platform mobile health companion engineered specifically for time-poor, desk-bound corporate professionals. The platform shifts away from traditional high-friction manual tracking, utilizing an ambient multi-agent network to intercept users during their workdays with hyper-contextual health interventions. 

### Core Value Proposition
* **Zero-Friction Logging:** Eliminates manual data entry via visual food parsing, passive biometric collection, and background smart-home integration.
* **Calendar-Aware Cadence:** Maps micro-interventions exclusively into real-time gaps in the user's corporate calendar.
* **Privacy First:** Rejects central server multi-tenancy, processing all data locally and saving state to user-owned cloud sandboxes.

---

## 2. High-Level System Architecture

The application is built on **Dart using the Flutter framework** to enforce absolute cross-platform pixel consistency via the Impeller rendering engine. The system implements strict **Clean Architecture (MVVM/BLoC)** to isolate logical execution blocks completely from visual components.

```text
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER (UI)              │
│  - Stateless Widgets (Dashboards, Tiles, Rings)        │
│  - Observer of State Streams                          │
└───────────────────────────▲────────────────────────────┘
                            │ (Immutable UI States)
┌───────────────────────────┴────────────────────────────┐
│                    DOMAIN LAYER (LOGIC)                │
│  - BLoC Controllers / Logic Objects                    │
│  - Pure Dart Execution (Zero UI Dependencies)          │
└───────────────────────────▲────────────────────────────┘
                            │ (Normalized Payloads)
┌───────────────────────────┴────────────────────────────┐
│                    DATA LAYER (SOCKETS)                │
│  - Samsung Health Socket   - Private Cloud Vault       │
│  - SmartThings IoT Plug    - Microsoft Graph API       │
└────────────────────────────────────────────────────────┘
```

### Decoupling Rules
1.  **Stateless Display Objects:** Tiles, widgets, and gauges are strictly forbidden from executing arithmetic calculations, data persistence tasks, or cryptographic logic. They accept data streams and output user interactions.
2.  **Unidirectional Data Flow:** User actions (e.g., tapping a hydration button) emit an intent event to the domain layer. The domain layer computes the update, transforms the data state, and emits a new, immutable layout package back to the view layer.

---

## 3. Security, Privacy, & Cloud Vault Framework

Syncora operates under a strict **Zero-Knowledge data lifecycle model**. The vendor maintains zero centralized user databases, completely removing remote infrastructure liability.

### A. Storage Paradigm: The Private Cloud Vault
* **Data Target:** All app state changes, profile parameters, and aggregated metrics are serialized into an encrypted database file stored in the user's personal, scoped **OneDrive Application Folder** via the `Files.ReadWrite.AppFolder` REST endpoint.
* **Cryptographic Keys:** Encryption keys are derived on-device using **PBKDF2 with SHA-256** using a hardware-backed random seed. Keys are safely isolated inside the mobile device's native hardware keystore (iOS Secure Enclave / Android Keystore System). 

### B. In-Memory Transient Processing Rules
To prevent data leaks, raw sensitive streams are restricted to volatile system memory buffers (RAM) and are permanently scrubbed immediately following evaluation.

| Core Data Category | Permanent Encrypted State (Cloud Vault) | Ephemeral Runtime State (RAM Only) |
| :--- | :--- | :--- |
| **Biometrics** | Daily normalized aggregates (Steps, Sleep Efficiency) | Raw high-frequency HRV tracks, real-time pulse lines |
| **Geospatial** | Abstract environment tags (`[Office Geofence]`) | Raw Latitude/Longitude coordinates from device GPS |
| **Dietary** | Calculated caloric and macronutrient integers (P/C/F) | Raw image file bytes captured by camera viewport |
| **Productivity** | Free/Busy duration blocks (e.g., `12-minute gap`) | Event subject text lines, invites, meeting descriptions |

### C. The Fortress Ingestion Scrubber
Before any data passes from integration sockets to local AI processing nodes, it undergoes automated sanitation:
1.  **EXIF Media Stripping:** Every image payload processed by the camera is forced through an in-memory buffer strip to clear geospatial tags, timestamps, and camera serial signatures.
2.  **Entity Masking:** Conversational inputs pass through regex pattern matching to identify and replace corporate project codes, email domains, and personal details with neutral tokens (`[PROJECT_BLOCK]`).

---

## 4. Feature Modules & Function Specs

### A. Cardio Engine
* **Passive Accumulation:** Merges physical step deltas from the Samsung Health socket.
* **Adaptive Recalculation:** If continuous desk sitting exceeds 180 minutes, the engine scales down workout intensity but preserves duration targets, transforming an aggressive evening regimen into a low-stress 25-minute metabolic walk.

### B. Diet Logistics & IoT Socket
* **Zero-Logging Interface:** Captures food receipts, descriptions, or meal snapshots via camera viewports, extracting nutritional data with zero alphanumeric text searching.
* **SmartThings Inventory Sync:** Connects to smart kitchen hubs (e.g., Samsung Family Hub) to extract active fridge assets.
* **Decision-Fatigue Override:** Features a `[ Generate Dinner From Fridge ]` routine. If an evening calendar block is open and active calorie tracking is deficient, the Master Agent builds a meal plan utilizing ingredients directly on hand.
* **Dietary Guardrails:** Automatically flags custom nutrition parameters (such as zero pork/ham/bacon boundaries) and provides dining suggestions for local cuisines (e.g., chicken biryani or butter chicken with minimized ghee) to manage dining out safely.

### C. Exercise & Discrete Stretching Vault
* **Time-Capped Sessions:** Limits physical movement targets to `10`, `15`, or `25-minute` intervals based on daily calendar availability.
* **Ergonomic Countermeasures:** Incorporates discrete desk routines targeted at corporate sitting strains (lumbar compression, forward-neck posture, carpal tunnel). Provides silent looping graphics allowing completion directly in an office workspace without drawing external attention.

### D. Leisure & Social Profiling Engine (LSPE)
* **Active Hobby Mapping:** Recognizes specialized movement contexts (e.g., tracking indoor bouldering or rock climbing sessions). When active, the system downscales routine core/strength alerts for 48 hours to prioritize wrist and grip recovery.
* **Recreational Load Compensation:** Tracks unique static physical strains, such as motorcycle riding profiles. Intercepts trips with target mobility sequences focused on relieving thoracic stiffness and hip-flexor tightening.

### E. Public Health Knowledge Agent
* Runs as an isolated asynchronous background agent separate from the user-facing interface.
* Ingests clinical research from verified repositories (PubMed, NIH, Harvard Health) and formats breakthroughs into structured JSON packages.
* Passes verified insights directly to the Master Agent to convert raw science into actionable suggestions (e.g., introducing under-desk soleus calf raises to elevate metabolism during static coding tasks).

---

## 5. UI/UX Interface, Components, & Themes

The interface focuses on high-end scannability, utilizing frosted glass components over deep backgrounds to reflect a calm, premium workspace.

### A. Primary Dashboard Layout
* **The Readiness Ring:** A top-level sweeping arc gauge tracking daily physiological recovery markers.
* **The Synco Intercept Banner:** A centered, floating glass panel with a glowing accent perimeter. Displays real-time, schedule-aware recommendations: *"Get 15 min at 12:30? Let's do a quick cardio walk."* Features an interactive **[Accept]** button to lock the session into the calendar system.
* **The Telemetry Matrix Grid:** Two-column grid containing ambient habit tracking modules: real-time step progress loops and a fluid-simulated hydration indicator panel.
* **The Micro-Launcher Action Bar:** A sticky horizontal control fixed above the bottom navigation tabs, launching immediate contextual movement blocks: `[ Start Next Session (3m Desk Stretch) ]`.

### B. Theme Engine Token Matrix

| Token Target | Executive Dark (Default) | Nordic Light | Cybernetic Matrix | Serene Focus |
| :--- | :--- | :--- | :--- | :--- |
| **Base Background** | Deep Slate (`#121820`) | Alabaster (`#F5F7FA`) | Obsidian Black (`#05070A`)| Espresso Taupe (`#1C1816`)|
| **Panel Style** | Frosted Dark (60%) | White Acrylic (75%) | Solid Charcoal (100%) | Sandstone Glass (65%) |
| **Primary Accent** | Energetic Sage (`#76C7A2`)| Eucalyptus (`#629A7D`) | Cyber Amber (`#E5A93C`) | Terracotta (`#D97450`) |
| **Data Vector Lines**| Muted Teal (`#4A909B`) | Ash Slate (`#333E48`) | Terminal Green (`#39FF14`)| Soft Cream (`#EAE3DB`) |

---

## 6. Telemetry Translation Module (TTM)

To ensure the interface continuously motivates the user toward their goals without causing notification fatigue, all numeric feedback components pass strings through the TTM middleware prior to display rendering.

```text
[Input Metric: Steps = 5,200] ──► [Query Profile State: Goal = POSTURE_PAIN_RELIEF]
                                                │
                                                ▼
[Output UI String: "5,200 steps complete — you've decompressed your lumbar spine for 40 minutes today."]
```
```