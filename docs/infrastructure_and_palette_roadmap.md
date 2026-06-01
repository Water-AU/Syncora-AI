# Syncora AI: Base Infrastructure & Component Palette Implementation Roadmap

## 1. Vision & Strategy
To build Syncora AI without experiencing prompt drift or UI distortion, the codebase must be established using **Component-Driven Development (CDD)**. Instead of assembling complete application layouts simultaneously, individual components—buttons, gauges, metrics tiles, and banners—are engineered and validated in absolute isolation inside a dedicated **Palette Dashboard (Component Sandbox)**.

### Architectural Benefits
* **Isolation of Concerns:** Eliminates dependencies on external APIs (Samsung Health, Microsoft Graph) during early-stage visual engineering.
* **Rapid Iteration:** Allows the Antigravity IDE agent to execute rapid build-and-test loops targeting one pixel-perfect container at a time.
* **Theme Stability:** Validates color token switching dynamically across all four application theme profiles before layouts are locked down.

---

## 2. Structural Implementation Sequence

```text
┌────────────────────────────────────────────────────────┐
│        PHASE 1: IMMUTABLE GLOBAL THEME TOKENS          │
│  - Define SyncoraTextStyle & SyncoraColorPalette       │
│  - Establish layout measurements and border radii       │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│        PHASE 2: GLOBAL STATE MANAGEMENT (BLoC)         │
│  - Deploy decoupled ThemeBloc and core state channels  │
│  - Implement runtime UI state stream channels          │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│        PHASE 3: THE COMPONENT PALETTE CANVAS           │
│  - Build the Scrollable Dev-Only Viewport              │
│  - Mount empty test tracks for visual components       │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│        PHASE 4: INCREMENTAL OBJECT DEPLOYMENT          │
│  - Build -> Verify -> Approve -> Transition to Prod   │
└────────────────────────────────────────────────────────┘
```

---

## 3. Detailed Phase Specifications

### Phase 1: Immutable Global Design Tokens
Establish a centralized theme dictionary file in pure Dart. This system abstracts all visual states so components remain entirely separate from static asset dependencies.

* **Target File:** `lib/core/theme/syncora_theme.dart`
* **Properties Specified:**
  * `baseBackground`: Tracks the specific background hex for each theme variant.
  * `panelBackground`: Governs the 60% translucent glass container configurations.
  * `primaryAccent`: Governs the target completion markers (Sage Green, Amber, etc.).
  * `telemetryLine`: Sets the custom styling tags for performance charts and vector data.

### Phase 2: State Management Scaffolding
Deploy a bare-bones Business Logic Component (BLoC) to manage user interactions and application state changes without altering display components.

* **Target Folder:** `lib/core/bloc/`
* **Properties Specified:**
  * `ThemeEvent`: Captures user requests to change themes (e.g., `ThemeEvent.toggle(ThemeProfile.nordicLight)`).
  * `ThemeState`: Emits updated, immutable styling objects across the root widget architecture.

### Phase 3: The Component Palette Workspace Canvas
Build a developer-focused, scrollable view page that serves as your live component inventory catalog.

* **Target File:** `lib/features/palette/presentation/pages/palette_dashboard_page.dart`
* **Visual Structure:** The page layout is organized into four separate, horizontal preview tracks:
  1. **Typography & Core Elements:** Displays text style models and standard glassmorphic containers.
  2. **Interactions & Controls:** Hosts custom actions, buttons, and haptic triggers.
  3. **Telemetry & Tracking Data:** Displays step meters, hydration waves, and indicator rings.
  4. **System Notification Banners:** Displays contextual information and prompt boxes.

### Phase 4: Step-by-Step Incremental Build Order
Once the canvas is established, the Antigravity IDE agent will develop and mount individual components in this precise sequence:

1. **Component A (The Core Shell):** The fundamental `GlassPanel` container featuring custom blur filters.
2. **Component B (The Arc Gauge):** The animated recovery indicator ring.
3. **Component C (The Intercept Banner):** The contextual scheduling card equipped with action button parameters.
4. **Component D (The Tracking Matrix):** The dual step and water wave progress trackers.
5. **Component E (The Micro-Launcher):** The fixed-bottom stretching panel.

---

## 4. Antigravity IDE Automation Script

Copy this complete instruction package and paste it into the Antigravity Agent Panel (`Ctrl+Shift+I`) to automatically initialize the foundation:

```text
Act as an expert Flutter and Dart software engineer. We are initiating Phase 1, 2, and 3 of the Syncora AI base infrastructure using a strict Component-Driven Development pattern.

Execute the following setup steps exactly:
1. Initialize a clean Flutter project structure with distinct core/ and features/ subdirectories.
2. Create the immutable design token engine file at `lib/core/theme/syncora_theme.dart` supporting our 4 design modes (Executive Dark, Nordic Light, Cybernetic Matrix, Serene Focus).
3. Implement a decoupled `ThemeBloc` state controller to handle dynamic, application-wide theme switching without modifying presentation layers.
4. Construct the dev-only testing template page at `lib/features/palette/presentation/pages/palette_dashboard_page.dart` containing empty placeholder rows for: 'Core Elements', 'Controls', 'Telemetry Tiles', and 'System Banners'.
5. Update `main.dart` to launch directly into the Palette Dashboard view for visual verification. Ensure the entire base codebase compiles with zero linting or type-checking errors.
```
```