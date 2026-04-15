---
name: pocketdo-ios-setup
description: >
  Complete setup skill for the PocketDo iOS application.
  Covers project architecture, design system, Xcode configuration, 
  dependency setup, and adding new features using the established
  Clean Architecture + MVVM pattern.
---

# PocketDo iOS – Setup & Development Skill

## Project Overview

**PocketDo** is a SwiftUI iOS productivity application following:
- **Architecture**: Clean Architecture + MVVM + Feature-based modular structure
- **Data Flow**: `View → ViewModel → UseCase → Repository → DataSource`
- **Design System**: "The Focused Curator" — defined in `DESIGN.md`

---

## 1. Prerequisites

Before opening Xcode, confirm:

```
- macOS 14+ (Sonoma)
- Xcode 16+
- iOS 17+ deployment target
- Swift 5.10+
- No CocoaPods or SPM external dependencies (project ships dependency-free initially)
```

---

## 2. Opening the Project

1. Open `pocketdo-ios.xcodeproj` in Xcode.
2. Select the `pocketdo-ios` scheme.
3. Choose a Simulator (iPhone 15 Pro recommended) or a real device.
4. Press ⌘R to build and run.

> **First build note**: You will see compiler errors if the old `pocketdo_iosApp.swift`
> entry point conflicts with the new `App/AppEntry.swift`. Delete the old file:
> In Xcode, right-click `pocketdo_iosApp.swift` → Delete → Move to Trash.

---

## 3. Folder Structure

```
pocketdo-ios/                  ← Xcode project root
├── App/
│   ├── AppEntry.swift         ← @main entry / scene
│   ├── AppRouter.swift        ← root route switcher (auth ↔ main)
│   ├── MainTabView.swift      ← glass tab bar + TabView
│   └── DependencyContainer.swift
│
├── Core/
│   ├── Theme/
│   │   └── AppTheme.swift     ← ALL design tokens (colors, type, spacing)
│   ├── Components/
│   │   └── AppComponents.swift ← PrimaryButton, TagChip, CardView, etc.
│   ├── Extensions/
│   │   ├── View+Extensions.swift
│   │   └── Date+Extensions.swift
│   └── Utilities/
│       └── AppError.swift
│
├── Domain/
│   ├── Entities/              ← Task, User, Tag
│   ├── UseCases/              ← TaskUseCases.swift  (Add/Fetch/Update/Delete/Sync/Login)
│   └── Repositories/          ← RepositoryProtocols.swift
│
├── Data/
│   ├── RepositoriesImpl/      ← TaskRepositoryImpl, AuthRepositoryImpl
│   └── DataSources/
│       ├── Local/             ← InMemoryTaskDataSource (swap for CoreData)
│       └── Remote/            ← FirebaseTaskDataSource (placeholder)
│
├── Features/
│   ├── Auth/
│   │   ├── Views/AuthView.swift
│   │   └── ViewModels/AuthViewModel.swift
│   ├── Dashboard/
│   │   └── Views/DashboardView.swift
│   ├── Task/
│   │   ├── Views/TaskListView.swift  (+ AddEditTaskView, FlowLayout)
│   │   └── ViewModels/TaskViewModel.swift
│   ├── Settings/
│   │   └── Views/SettingsView.swift
│   └── Premium/
│       └── Views/PremiumView.swift
│
└── Services/
    └── AppServices.swift      ← AuthService, SyncService, SubscriptionService
```

---

## 4. Custom Fonts Setup

The design system requires **Manrope** (headlines) and **Inter** (body/labels).

### Steps:
1. Download [Manrope](https://fonts.google.com/specimen/Manrope) and [Inter](https://fonts.google.com/specimen/Inter).
2. Add the `.ttf` files to `pocketdo-ios/Resources/Fonts/`.
3. Add all font files to the Xcode target (check "Add to target" when importing).
4. In `Info.plist`, add the key `Fonts provided by application` (array) and list each `.ttf` filename.

### Required font weights:
```
Manrope-Bold.ttf
Manrope-SemiBold.ttf
Inter-Regular.ttf
Inter-Medium.ttf
Inter-SemiBold.ttf
```

### Fallback: If fonts are not loaded yet
Replace `Font.custom(...)` calls in `AppTypography` with system equivalents:
```swift
static let headlineLg = Font.system(size: 32, weight: .bold, design: .rounded)
static let bodyMd     = Font.system(size: 14, weight: .regular)
```

---

## 5. Fixing the Duplicate App Entry Point

After scaffolding, delete the original entry file to avoid `@main` conflicts:

1. In Xcode Navigator, find `pocketdo_iosApp.swift`
2. Right-click → **Delete** → **Move to Trash**
3. Also delete `ContentView.swift` (replaced by feature views)

---

## 6. Adding Charts Framework

The `DashboardView` uses `import Charts` (Apple Charts, available iOS 16+).

**Action required**: In Xcode, the Charts framework is built-in — no SPM package needed. Just ensure your deployment target is iOS 16+:

`Project → pocketdo-ios target → General → Minimum Deployments → iOS 16.0`

---

## 7. Design System Reference

All design tokens live in `Core/Theme/AppTheme.swift`. **Never hardcode colors or fonts in feature views.** Always use:

### Colors
```swift
Color.appPrimary           // #3525cd  deep Indigo
Color.appSecondary         // #006e2f  lush Green
Color.appSurface           // #ffffff  card background
Color.appBackground        // #f3f4f5  page background
Color.appOnSurface         // #1a1a2e  primary text
Color.appOnSurfaceVariant  // #5c5c7a  secondary text
```

### Typography
```swift
AppTypography.headlineLg   // Manrope Bold 32pt  — page titles
AppTypography.titleMd      // Inter Medium 16pt  — task titles
AppTypography.bodyMd       // Inter Regular 14pt — descriptions
AppTypography.labelSm      // Inter Regular 11pt — timestamps
```

### Spacing (8pt grid)
```swift
AppSpacing.xs   // 8
AppSpacing.md   // 16
AppSpacing.lg   // 24  ← standard screen horizontal padding
AppSpacing.xl   // 32
```

### Shadows (never use Color.black)
```swift
.appShadow(.card)   // subtle card lift
.appShadow(.float)  // FAB / bottom nav float
.appShadow(.sheet)  // modal sheet
```

### Gradients
```swift
AppGradients.primaryCTA    // Indigo → primary_container (buttons, FAB)
AppGradients.heroBackground // subtle hero bleed for auth screen
AppGradients.glassSurface   // translucent for bottom nav
```

---

## 8. Adding a New Feature

Follow this checklist when adding a new feature module:

### Step 1 – Domain Layer
```
Domain/Entities/MyEntity.swift          ← struct MyEntity: Identifiable
Domain/Repositories/MyRepository.swift  ← protocol MyRepository { ... }
Domain/UseCases/MyUseCases.swift        ← struct MyUseCase { func execute() }
```

### Step 2 – Data Layer
```
Data/DataSources/Local/LocalMyDataSource.swift
Data/RepositoriesImpl/MyRepositoryImpl.swift
```

### Step 3 – Feature Layer
```
Features/MyFeature/
├── ViewModels/MyViewModel.swift   ← @MainActor final class, @Published props
└── Views/MyView.swift             ← SwiftUI View, receives VM via @StateObject
```

### Step 4 – Wire into DependencyContainer
```swift
// In DependencyContainer.swift:
lazy var myRepository: MyRepository = MyRepositoryImpl(...)
func makeMyUseCase() -> MyUseCase { MyUseCase(repository: myRepository) }
```

### Step 5 – Register tab/navigation in AppRouter / MainTabView

---

## 9. Switching from In-Memory to CoreData

1. Create `Data/DataSources/Local/CoreDataTaskDataSource.swift`
2. Implement `LocalTaskDataSource` protocol using `NSPersistentContainer`
3. In `DependencyContainer`, replace:
   ```swift
   lazy var localTaskDataSource: LocalTaskDataSource = InMemoryTaskDataSource()
   // with:
   lazy var localTaskDataSource: LocalTaskDataSource = CoreDataTaskDataSource()
   ```

---

## 10. Firebase Integration

1. Add Firebase SDK via SPM: `https://github.com/firebase/firebase-ios-sdk`
   - Add packages: `FirebaseAuth`, `FirebaseFirestore`
2. Download `GoogleService-Info.plist` and add to the Xcode target
3. In `Data/DataSources/Remote/RemoteTaskDataSource.swift`, implement `FirebaseTaskDataSource`
4. Update `TaskRepositoryImpl` to perform local ↔ remote sync

---

## 11. StoreKit 2 (Premium)

1. Enable In-App Purchases capability in Xcode → Signing & Capabilities
2. Create product IDs in App Store Connect
3. Implement `SubscriptionServiceImpl` using `StoreKit.Product.purchase()`
4. Update `PremiumView` to use real product SKUs

---

## 12. Common Gotchas

| Issue | Fix |
|-------|-----|
| `@main` conflict | Delete old `pocketdo_iosApp.swift` |
| Font not found | Verify `.ttf` in target + `Info.plist` Fonts key |
| Charts crash on iOS 15 | Set deployment target to iOS 16+ |
| `Task` name conflict with Swift concurrency | Rename domain entity to `TodoTask` if needed |
| `DependencyContainer` double init | Pass container via `.environmentObject()` from `AppEntry` |

---

## 13. Code Quality Rules

- ✅ Business logic belongs **only** in UseCases and Repositories
- ✅ ViewModels are `@MainActor final class` with `@Published` properties
- ✅ Views are `struct` — no business logic
- ✅ All async calls use `async/await` — no Combine publishers for data loading
- ✅ No `singleton` pattern — use `DependencyContainer`
- ❌ No hardcoded colors, fonts, or spacing
- ❌ No `1px` border separators (design rule)
- ❌ Never `import UIKit` in feature views unless required for UIKit interop
