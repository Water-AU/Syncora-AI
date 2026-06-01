# Syncora AI: Master Functional Specification & Component Ledger

## 1. Functional Intent & Scope Boundary
This document defines the operational behavior, data flows, and state requirements for Syncora AI. It maps the technical design specifications into discrete, buildable software components. Every button, tile, widget, and dashboard screen documented here must be implemented using **Dart and Flutter**, adhering to a strict separation of presentation layouts from business logic via the **BLoC (Business Logic Component)** pattern.

---

## 2. Functional Architecture & State Management Flow
To preserve the "Logic vs. Display" boundary, all interactive elements must conform to a unidirectional state delivery pipeline. Display components are strictly prohibited from mutating data directly.

```text
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION OBJECTS                 │
│  Emits UI Events ───────────────────────────────┐     │
│  ▲ Receives Immutable UI States                 │     │
└──┼──────────────────────────────────────────────┼─────┘
   │                                              ▼
┌──┴──────────────────────────────────────────────┴─────┐
│                    DOMAIN LOGIC (BLoC)                 │
│  Processes Event ──► Fetches Data ──► Computes State  │
└───────────────────────────▲───────────────────────────┘
                            │
┌───────────────────────────┴───────────────────────────┐
│                    DATA ACCESSIBILITY                 │
│  Encrypted Cloud Vault (Stream) ◄──► Hardware Crypt   │
└───────────────────────────────────────────────────────┘
```

### Universal Component Interaction Rules
1. **Event Dispatch:** A user interaction (e.g., tapping a widget button) triggers an explicit, type-safe event sent to the respective BLoC controller (e.g., `DashboardEvent.onAcceptIntercept`).
2. **State Mutation:** The BLoC controller calculates the operational adjustments, strips any sensitive identifiers using the local security library, executes in-memory persistence configurations, and outputs an immutable state model (e.g., `DashboardState.success`).
3. **UI Re-Render:** The UI layer listens via a `BlocBuilder` or `StreamBuilder` and visually updates the glassmorphic panels dynamically based on the current state.

---

## 3. Core Feature Workflows & Logic Maps

### A. The Cardio Engine Loop
* **Inputs:** Continuous passive step counts, background active calorie burns, and historical heart rate limits aggregated via the Samsung Health socket.
* **Logic Rules:**
  * If the active user profile exhibits a `DESK_BOUND` constraint and the background tracker registers more than 180 minutes of static sitting time, the engine intercept runs.
  * The evening workout targets are dynamically scaled down in complexity (e.g., shifting an active running metric into a low-stress 25-minute walk) to prioritize active recovery over exhaustion.

### B. The Zero-Friction Diet Logistics & IoT Loop
* **Inputs:** Multi-modal inputs (meal snapshot buffers, textual receipt strings) alongside live kitchen inventories provided by the SmartThings Cooking API sandbox.
* **Logic Rules:**
  * The system verifies user dietary boundaries (e.g., enforcing an absolute filter removing pork, ham, or bacon inputs).
  * Clicking `[ Generate Dinner From Fridge ]` commands the background agent to cross-reference available proteins and vegetables expiring within 48 hours to assemble step-by-step recipes requiring zero shopping friction.
  * If an off-site dining destination is flagged on the calendar (such as an evening social dinner at an Indian restaurant), the engine adjusts surrounding caloric bounds and elevates the subsequent 12-hour hydration target automatically.

### C. The Discrete Stretching Vault
* **Inputs:** Continuous user schedule availability markers extracted via Microsoft Graph or corporate calendar connectors.
* **Logic Rules:**
  * The system locates unallocated 10-to-15-minute intervals between consecutive meetings.
  * It triggers localized, office-chair-friendly stretching options (carpal tunnel relief, neck alignment, lumbar decompression) using silent looping graphics that allow users to maintain workspace progress unobtrusively.

### D. Leisure & Social Profiling Engine (LSPE)
* **Inputs:** Leisure scheduling tags, digital entry passes, and geolocation history categories.
* **Logic Rules:**
  * **Active Hobbies:** When a high-yield functional activity like indoor climbing or bouldering is recognized, the domain layer automatically scales down standard upper-body metrics for 48 hours to focus on wrist and finger recovery.
  * **Recreational Travel:** Identifies distinct static postures (e.g., forward-leaning isometric loading from motorcycle riding). Triggers post-trip targeted recovery routines focused on thoracic spine extension and hip flexor mobilization.

---

## 4. Comprehensive Component & Widget Ledger

This ledger defines the exact specifications for the Antigravity IDE agent to construct the application layout components in a precise, step-by-step sequence.

### Dashboard Screen Components (Main Hub Canvas)

#### Component 1: The Daily Readiness Arc Gauge
* **Functional Scope:** Renders an animated, semi-circular progress arc showing physical recovery metrics based on sleep and resting heart rate data.
* **UI Properties:** Uses a glowing indicator ring. The gauge path dynamically transitions from green (`#76C7A2`) to amber based on data inputs.
* **State Boundaries:** Displays a static loader if data synchronization is active. Clicking the component triggers an event pushing the layout into the high-level tablet analytics summary.

#### Component 2: The Synco Intercept Banner
* **Functional Scope:** Displays high-priority contextual interventions pushed directly by the multi-agent orchestration layer.
* **UI Properties:** Constructed as a glassmorphic container using `#1A232E` with 60% opacity and a `backdrop-filter: blur(20px)` styling block. Includes a subtle, pulsing perimeter glow aura, a clean avatar graphic on the left, and a primary action CTA button.
* **Button Target:** `[ Accept ]` (Color: `#76C7A2`). Tapping this fires a background command that injects the recovery event directly into the user's work calendar and stages the corresponding exercise module.

#### Component 2A: The Telemetry Matrix Grid
* **Functional Scope:** A 2-column modular dashboard container tracking real-time baseline values.
* **UI Properties:** Two flanking glassmorphic cards.
  * **Card A (Steps):** Renders a clean progress ratio text (e.g., `8,421 / 12K`) centered within a minimal vector progress ring.
  * **Card B (Hydration):** Contains a custom vector water wave asset that dynamically adjusts its vertical height inside the panel based on target completion metrics.
* **Button Target:** A micro `[ + ]` icon on the hydration card that increases tracked water intake by 250ml per click without shifting the screen focus.

#### Component 2B: The Micro-Launcher Action Bar
* **Functional Scope:** A fixed-bottom horizontal interactive strip providing immediate access to low-time recovery movements.
* **UI Properties:** Stretches across the full screen width right above the primary navigation bar. Text labels dynamically update based on time constraints (e.g., "Quick Desk Stretch (3m)").
* **Button Target:** `[ Start ]` (Color: Solid `#76C7A2`). Clicking this opens a full-screen modal layer displaying looping, silent instructional mechanics.

---

### Diet Tracker Screen Components

#### Component 3: The Visual Input Vault Viewport
* **Functional Scope:** Provides a custom camera portal for zero-friction nutritional logging.
* **UI Properties:** A large rectangular bounding window embedded with sharp crosshair graphics to assist target framing.
* **State Boundaries:** Displays an animated processing pulse while the background agent strips metadata and parses macronutrient estimates.

#### Component 3A: Concentric Macro Wheels
* **Functional Scope:** Tracks remaining daily macronutrient allocations visually.
* **UI Properties:** Three overlaying, neon-accented tracking circles representing Protein, Carbohydrates, and Fats.
* **State Boundaries:** The wheels fill progressively based on the verified input structures received from the image parsing engine.

#### Component 3B: The Smart Fridge Inventory Carousel
* **Functional Scope:** Surfaces the real-time kitchen inventory assets pulled from the SmartThings API socket.
* **UI Properties:** A horizontal scroll view containing item thumbnail text cards. Cards for ingredients nearing expiration switch their borders to a soft amber glow automatically.
* **Button Target:** `[ 🍳 Generate Dinner From Fridge ]`. Fires a request to the local Master Agent to output a recipe based entirely on available ingredients.

---

### External Operating System Components (OS Widgets)

#### Component 4: The Energy Battery Widget (Size: 1x1)
* **Functional Scope:** Displays current energy metrics directly on the mobile home screen interface.
* **UI Properties:** Minimalist battery graphic framing the core numerical value (e.g., `78%`). Tapping the layout launches the app directly into the AI Coach Chat module with pre-loaded optimization recommendations.

#### Component 4A: The Time-Gap Launcher Widget (Size: 2x1)
* **Functional Scope:** Tracks upcoming availability windows detected in the work calendar.
* **UI Properties:** Displays an indicator text line (e.g., "15 min gap at 12:45 PM") paired with an actionable trigger button. Tapping the button bypasses standard loading screens and initializes the desk stretching module instantly.

---

## 5. Security & Privacy Processing Implementation Rules

To ensure compliance with the Zero-Knowledge specifications, the data processing layer must enforce the following functional behaviors:

1. **In-Memory Image Scrubbing:** When a photo is captured by Component 3, the raw byte array must pass through an isolation handler that strips out all EXIF header metadata before any processing occurs. The source file must be scrubbed from system memory immediately after the macronutrient values are calculated.
2. **Calendar Content Anonymization:** When parsing calendar events for availability gaps, the data socket must discard all descriptive meeting notes, attendee lists, and subject text lines. It is permitted to extract only the start time, end time, and availability status (`Free`/`Busy`).
3. **Local Encrypted File Synchronization:** The data synchronization layer must batch updates into an encrypted SQLite configuration or JSON database model. This database payload must be encrypted using **AES-256-GCM** before being written directly to the user's isolated private cloud directory via the application container endpoints.

---

## 6. Verification & Test-Driven Checklist Ledger

The Antigravity agent must verify each component against these runtime execution parameters:

* [ ] **Test Case 1:** Verify the `Daily Readiness Arc Gauge` shifts color tokens correctly when a low-recovery profile payload (e.g., sleep efficiency under 50%) is injected into the logic pipeline.
* [ ] **Test Case 2:** Assert that tapping `[ Accept ]` on the `Synco Intercept Banner` generates a calendar event entry via the mock scheduling API without crashing the visual rendering thread.
* [ ] **Test Case 3:** Verify that the `Telemetry Translation Module (TTM)` correctly catches raw step counts and outputs custom user-intent text labels for the `Telemetry Matrix Grid` components.
* [ ] **Test Case 4:** Confirm the `Visual Input Vault Viewport` correctly strips metadata from image buffers, and check that the asset is completely erased from system memory after macro integers are produced.
```