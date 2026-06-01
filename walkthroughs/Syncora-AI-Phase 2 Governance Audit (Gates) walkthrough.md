# Syncora AI: Architecture Governance Audit (Phase 2 Gates)

## Module Scaffolding Completed
I have successfully implemented the automated validation module at [`bin/architecture_audit.dart`](file:///c:/Users/a428037/Development/AntiGravity/Syncora-AI/bin/architecture_audit.dart). This script operates as a standalone evaluator designed to scan the project files and enforce our architectural invariants. 

## Invariants Enforced

### Rule 1: UI Pure Presentation Rule
- **Target Area:** `lib/features/palette/presentation/widgets/` & `lib/features/palette/presentation/pages/`
- **Validation Engine:** The script uses regex analysis to search for hardcoded string equivalence (`== '...'`) and specific static type lookups (`ThemeProfile.X`) inside presentation components. 
- **Enforcement:** Components failing this check flag the matrix with a `[FAILED]` status, ensuring that UI components remain "dumb skins" bound purely to theme properties rather than structural logic blocks.

### Rule 2: State Isolation Rule
- **Target Area:** `lib/core/bloc/`
- **Validation Engine:** Scans files line-by-line for the presence of `import 'package:flutter/material.dart';` or related component libraries.
- **Enforcement:** Binds domain and bloc layer files to strictly pure state logic, immediately flagging failures if presentation code leaks into our Core BLOC architecture.

## How to Trigger the Audit inside PowerShell

To trigger this compliance module from your active PowerShell environment, invoke the standalone script using the Dart CLI. 

1. Ensure your terminal is running at the workspace root directory:
```powershell
cd C:\Users\a428037\Development\AntiGravity\Syncora-AI
```

2. Execute the validation script natively:
```powershell
dart bin/architecture_audit.dart
```

### Automation & CI Integration Pipeline
Because the script utilizes system exit codes (e.g., `exit(1)` on failure and `exit(0)` on pass), it naturally breaks standard CI pipelines in GitHub Actions, GitLab CI, or Jenkins if an invariant is violated. 

You can also chain this onto your standard Flutter checks in your local PowerShell workflow like this:
```powershell
dart bin/architecture_audit.dart ; if ($?) { flutter analyze ; flutter test }
```
*(This ensures standard analysis and tests only proceed if the architectural integrity audit successfully clears).*
