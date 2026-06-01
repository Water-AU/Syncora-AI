# Syncora AI: Core Engineering & Architecture Rules

## 1. Technology Stack Selection
* **Language:** Dart (Type-Safe, AOT Compiled)
* **Framework:** Flutter (Utilizing the Impeller rendering engine for cross-platform UI locked state)

## 2. Separation of Concerns (The Architectural Wall)
* No business logic, API orchestration, or cryptographic operations are permitted within the widget layout tree.
* All component views must implement the Business Logic Component (BLoC) or pure MVVM model.
* UI elements must act as stateless observers of data changes emitted by logical components.

## 3. Data Privacy & Processing Pipelines
* All application telemetry must be managed inside volatile, in-memory blocks.
* Permanent state changes must be serialized directly into encrypted data payloads bound for the user's private application cloud directory.