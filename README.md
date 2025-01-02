<div align="center">

# POCKETDO IOS 🚀

### Minimalist local-first task manager for iOS using CoreData and SwiftUI

![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=for-the-badge&logo=swift&logoColor=white) ![iOS](https://img.shields.io/badge/iOS-16+-000000?style=for-the-badge&logo=apple&logoColor=white) ![Xcode](https://img.shields.io/badge/Xcode-15-147EFB?style=for-the-badge&logo=xcode&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge)
![Stars](https://img.shields.io/github/stars/ram7767/pocketdo-ios?style=for-the-badge)

</div>

---

## ✨ Features

| Feature | Status |
|---------|--------|
| 🔐 User Authentication | ✅ |
| 💬 Real-time Updates | ✅ |
| 📦 Offline Support | ✅ |
| 🌙 Dark Mode | ✅ |
| 🔔 Push Notifications | ✅ |
| 🧪 Unit Tests | ✅ |

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
Presentation Layer   →   Domain Layer   →   Data Layer
    (UI/Views)             (UseCases)        (Repos/APIs)
```

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| Language | Swift 5.9 |
| UI Framework | SwiftUI / UIKit |
| Reactive | Combine |
| Database | CoreData / Firebase |
| Networking | URLSession / Alamofire |
| Testing | XCTest |

---

## 🚀 Getting Started

### Prerequisites

- Xcode 15+
- iOS 16+ simulator or device
- CocoaPods or SPM

### Installation

```bash
# Clone the repository
git clone https://github.com/ram7767/pocketdo-ios.git
cd pocketdo-ios

# Install dependencies
pod install

# Open in Xcode
open pocketdo-ios.xcworkspace
```

---

## 📁 Project Structure

```
pocketdo-ios/
├── pocketdo-ios/
│   ├── App/              # App entry point
│   ├── Features/         # Feature modules
│   │   ├── Auth/
│   │   ├── Home/
│   │   └── Profile/
│   ├── Core/             # Shared utilities
│   │   ├── Network/
│   │   ├── Database/
│   │   └── Extensions/
│   └── Resources/        # Assets, fonts
├── Tests/
└── README.md
```

---

## 🗺️ Roadmap

- [x] Core architecture setup
- [x] Authentication flow
- [x] Main feature implementation
- [x] Offline support
- [ ] iPad / tablet layout
- [ ] Localization (i18n)
- [ ] Performance optimizations
- [ ] App Store / Play Store release

---

## 🤝 Contributing

Contributions are warmly welcome!

1. Fork the repository
2. Create your branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'feat: add amazing feature'`
4. Push the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for details.

---

<div align="center">

Made with ❤️ by [@ram7767](https://github.com/ram7767)

⭐ Star this repo if you found it helpful!

</div>
