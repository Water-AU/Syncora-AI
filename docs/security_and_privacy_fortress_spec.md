# Syncora AI: Security, Privacy, and Data Isolation Architecture Specification

## 1. Security Intent & Trust Boundaries
Syncora AI implements a decentralized, **Zero-Knowledge data lifestyle model**. The technical design explicitly rejects central-server multi-tenancy, third-party user data persistence, and remote analytics logging. The user's device and their personal, isolated cloud workspace constitute the absolute boundary of trusted execution.

### The Core Trust Axioms
* **Zero Vendor Liability:** The application architecture guarantees that the platform vendor has zero physical or logical capability to view, modify, or intercept user health profiles, calendars, or lifestyle streams.
* **Local Cryptographic Origin:** All encryption keys originate within the device's local hardware-backed secure storage and are never transmitted over an external network interface.
* **Data Sovereign Cloud Sync:** Storage virtualization leverages the user's personal cloud directory as a raw storage socket, creating an encrypted personal sanctuary.

---

## 2. Decentralized Cryptographic Vault Architecture

Data persistence uses an abstract storage provider layer that encrypts a local SQLite binary database instance before streaming it to a scoped application folder (e.g., OneDrive `Files.ReadWrite.AppFolder` or Google Drive `drive.appdata` sandbox containers).

```text
┌────────────────────────────────────────────────────────┐
│               LOCAL DEVICE SANDBOX SECURE BOUNDARY     │
│                                                        │
│  ┌──────────────────┐        ┌──────────────────────┐  │
│  │ Secure Enclave / │────────► Hardware Key Deriv.  │  │
│  │ Android Keystore │        │ (PBKDF2 SHA-256)     │  │
│  └──────────────────┘        └──────────┬───────────┘  │
│                                         │              │
│  ┌──────────────────┐                   ▼              │
│  │ In-Memory Engine │◄─────── AES-256-GCM Cipher Block │
│  └────────┬─────────┘                                  │
└───────────┼────────────────────────────────────────────┘
            │
            ▼ (Encrypted Ciphertext Stream Only)
┌────────────────────────────────────────────────────────┐
│             USER-OWNED PRIVATE CLOUD STORAGE           │
│                                                        │
│  🔒 syncora_vault.db                                   │
└────────────────────────────────────────────────────────┘
```

### A. Encryption at Rest (The Cipher Stack)
* **Algorithm:** Symmetric file assets utilize **AES-256-GCM** (Advanced Encryption Standard in Galois/Counter Mode).
* **Authentication:** Authenticated Data (AEAD) tags verify database payload integrity during runtime sync events. Any external file tampering outside the local app sandbox instantly invalidates the tag check, causing the application to lock access and protect data integrity.

### B. Key Derivation & Hardware Isolation
* **Seed Generation:** A cryptographically secure random number generator (CSRNG) creates a 256-bit initialization seed on the device during the onboarding sequence.
* **Key Stretching:** The system derives working operational keys via **PBKDF2** (Password-Based Key Derivation Function 2) running a SHA-256 hashing architecture over 100,000 iterations.
* **Storage Token:** The derived key configuration is injected directly into the platform hardware keychain layer (iOS Secure Enclave / Android Keystore System). It is bound to device bio-authentication metrics, rendering it inaccessible to other software processes running on the host OS.

---

## 3. Data Isolation Sockets & Transient Processing Pipelines

To ensure sensitive third-party metadata never slips into permanent storage, the application logic enforces a strict segregation matrix between permanent vault persistence and ephemeral memory buffers.

### Ephemeral Lifecycle Rules
1. **Volatile Memory Allocation:** Sensitive API payloads (raw text body data, image pixels, coordinate variables) map straight to in-memory byte buffers (RAM).
2. **Immediate Zeroing:** As soon as the Domain Logic layer extracts the required numeric or structural metrics, the active memory sectors are explicitly zeroed out and garbage collected.

```text
[Data Socket Payload Ingest] ──► [In-Memory Processing Buffer] ──► [Metric Extracted] ──► [Memory Sector Zeroed]
```

### The System Memory Isolation Matrix

| Functional Module | Data Written to Vault (Encrypted Only) | Data Kept in Ephemeral Memory (Purged Instantly) |
| :--- | :--- | :--- |
| **Cardio Engine** | Normalized daily totals (Steps, Active minutes, Active Burn Kcal). | High-frequency continuous HRV sequences, raw pulse frequency logs. |
| **Diet Logistics** | Computed daily calorie boundaries, absolute macro integers (P/C/F). | Raw food capture camera image buffers, metadata headers, receipts. |
| **Stretching Vault** | Completed exercise string identifiers, duration time blocks. | Corporate calendar text content, attendee listings, invite titles. |
| **Social Engine** | Leisure category flags (`Active Hobby`, `Dining Hub`). | Absolute GPS coordinates, physical venue street addresses. |

---

## 4. The Privacy Fortress Ingestion Scrubber

Before any unstructured external payload crosses the boundary into the local Multi-Agent network, it must pass through the automated serialization filters of the **Privacy Fortress Layer**.

### Ingestion Sanitation Protocols

#### Protocol 1: EXIF Metadata Demolition
Every byte stream captured by the food logging camera component or receipt scanner undergoes a destructive byte wash. All exchangeable image file format (EXIF) attributes—including capture device signatures, exact geostamps, orientation tags, and time parameters—are forcefully deleted.

```dart
// Conceptual Data Layer Enforcement
Future<Uint8List> sanitizeImageBytes(Uint8List rawBytes) async {
  final inMemoryBuffer = MemoryImageModifier(rawBytes);
  inMemoryBuffer.stripExifHeaders();
  return inMemoryBuffer.getCleanDataStream();
}
```

#### Protocol 2: Relative Geolocation Masking
To prevent tracking historical travel pathways, absolute coordinate positions are processed entirely within a local runtime controller. They are matched against general proximity perimeters and immediately translated into abstract environment classification models.
* Raw coordinate tracking data is never cached or stored.
* The data translates exclusively into structural system tags: `ContextProfile.OfficeCore`, `ContextProfile.HomeBase`, or `ContextProfile.TransitCorridor`.

#### Protocol 3: Natural Language Entity Masking
Unstructured chat text payloads provided by the user pass through an automated scanning module prior to processing. High-speed regex tokenizers detect, flag, and mask sensitive corporate or personal identifying expressions.

```text
"Finalizing the deployment specs for Project Genesis over at ATOS domain"
                              │
                              ▼ (Fortress Filter Processing)
"Finalizing the deployment specs for [PROJECT_BLOCK] over at [ORGANIZATION_BLOCK]"
```

---

## 5. UI Component & Widget Security Frameworks

Every presentation element in the Flutter view tree mirrors these privacy boundaries, maintaining clean data isolation across display fields.

### A. The Dashboard Screens
* **The Readiness Arc Gauge:** Operates purely on pre-calculated daily summary values. It lacks access channels to high-frequency heart patterns or sleep logging telemetry.
* **The Synco Intercept Banner:** Ingests only the duration profile of an upcoming calendar gap. The text formatting algorithm has zero access to meeting titles, calendar descriptions, or corporate invitation parameters.
* **The Telemetry Matrix Grid:** Pushes step and hydration quantities to the display engine as absolute integers. The UI code handles no direct integration connections to the raw external web sockets.

### B. The Diet Tracker Viewport
* **The Visual Input Vault:** Leverages a custom, stateless camera loopback controller. Captured visual streams populate an isolated frame window and do not save temporary images to the public OS photo gallery or local application caches.
* **Smart Fridge Inventory Carousel:** Ingests an abstracted list of raw ingredient names and categories. It is restricted from pulling unique manufacturing signatures, internal hub identifiers, or home infrastructure mapping properties.

### C. OS Widgets & Smartwatch Complications
* **The Energy Battery Widget (1x1):** Holds look-access tokens for a single composite integer string value (`78%`). It lacks internal logic paths to read or display detailed biographical structures.
* **The Time-Gap Launcher Widget (2x1):** Receives only the numerical start time and block size of the next available gap. It works independently of scheduling descriptions to prevent data exposure on a locked mobile home screen interface.

---

## 6. Security Verification & Automated Audit Ledger

The Antigravity agent must run local test checks to ensure the data isolation boundaries function correctly under edge-case conditions.

* [ ] **Audit Test 1 (Zero-Knowledge Validation):** Assert that dropping or deleting the device's local keystore token completely disables database decryption, ensuring third-party tools cannot parse the data vault file inside OneDrive.
* [ ] **Audit Test 2 (Scrubber Performance):** Verify that injecting an un-sanitized image file containing active GPS EXIF headers into the `Visual Input Vault` runtime channel returns a processed data model with all image metadata headers completely removed.
* [ ] **Audit Test 3 (Entity Masking Verification):** Ensure that passing string configurations containing live email addresses, domain links, or text markers into the onboarding logic returns fully anonymized data payloads before passing the elements to the domain models.
* [ ] **Audit Test 4 (Memory Leak Leakage Test):** Verify through memory profiling tracks that raw text blocks extracted from the calendar data sockets are completely cleared and zeroed out from system memory buffers once the duration availability boundaries are computed.
```