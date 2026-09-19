# 🏛️ JWO Welfare System

<div align="center">

### Flutter & Firebase Mobile Application for Jalal Welfare Organization

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

📍 **Jalal Welfare Organization** — Village Badalai, Tehsil Wari, District Dir Upper, Pakistan

</div>

---

## 📱 About the App

The **JWO Welfare System** is the official mobile application for **Jalal Welfare Organization (جلال فلاحی تنظیم)**. It connects donors, volunteers, and those in need through a single, easy-to-use platform.

This app digitizes the organization's welfare operations with features for donations, volunteering, help requests, news updates, and organizational information.

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🔐 **User Authentication** | Secure registration and login with email verification |
| 👤 **Profile Management** | Manage personal info: name, father's name, phone, address, blood group, CNIC |
| 💰 **Donation Management** | Submit donations with QR code verification for transparency |
| 🤝 **Volunteer Application** | Apply with CV upload, skills, and experience tracking |
| 📝 **Help Requests** | Submit and track requests for assistance |
| 📰 **News & Updates** | Real-time news ticker with organization announcements |
| 📜 **Constitution** | Access JWO's complete constitution and by-laws |
| 🏛️ **Executive Body** | View leadership in Pakistan and Saudi Arabia |
| 📱 **JWO Activities** | View events, images, videos, and updates |
| 💳 **Digital Cards** | Volunteer and donation cards for members |
| 📞 **Contact & About** | Organization contact information and mission |

---

## 🛠️ Tech Stack

### Frontend

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)

### Backend & Cloud

![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Firestore](https://img.shields.io/badge/Cloud%20Firestore-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Firebase Auth](https://img.shields.io/badge/Firebase%20Auth-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Firebase Storage](https://img.shields.io/badge/Firebase%20Storage-FFCA28?style=flat-square&logo=firebase&logoColor=black)

### Additional Services

- **EmailJS** — Transactional emails (verification, volunteer cards)
- **Mobile Scanner** — QR code verification for donations
- **File Picker** — CV/resume uploads

---

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── create_admin.dart                  # Admin creation utility
├── firebase_options.dart              # Firebase configuration
│
├── models/                            # Data models
│   ├── activity_model.dart
│   ├── card_model.dart
│   ├── donation_model.dart
│   ├── news_model.dart
│   ├── request_model.dart
│   ├── user_model.dart
│   └── volunteer_model.dart
│
├── screens/                           # UI screens
│   ├── splash_screen.dart
│   ├── login.dart
│   ├── signup.dart
│   ├── home.dart
│   ├── profile.dart
│   ├── donation.dart
│   ├── volunteer.dart
│   ├── request_help.dart
│   ├── jwo_activities.dart
│   ├── constitution.dart
│   ├── executive_body.dart
│   ├── my_cards.dart
│   ├── contact_us.dart
│   ├── about_us.dart
│   ├── forgot_password.dart
│   ├── email_verification_check.dart
│   └── admin/                         # Admin screens
│       ├── admin_dashboard.dart
│       ├── admin_news.dart
│       ├── admin_volunteers.dart
│       ├── admin_requests.dart
│       ├── admin_donations.dart
│       └── admin_activities.dart
│
├── services/                          # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── storage_service.dart
│   ├── admin_service.dart
│   └── emailjs_service.dart
│
└── widgets/                           # Reusable widgets
    ├── news_ticker.dart
    └── custom_icons.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Android Studio or VS Code
- Firebase project configured
- Google Services JSON file

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/nawab-ali45/JWO-Flutter-project.git
   cd JWO-Flutter-project
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Set up Firebase:**
   - Create a Firebase project
   - Add Android app with package name: `com.jalalwelfare.organization`
   - Download `google-services.json`
   - Place it in `android/app/google-services.json`

4. **Set up signing (for release):**
   - Create `android/key.properties` with your keystore info
   - Add your keystore file to `android/app/`

5. **Run the app:**

   ```bash
   flutter run
   ```

6. **Build for release:**

   ```bash
   flutter build appbundle --release
   ```

---

## 📋 Requirements

| Requirement | Version |
|-------------|---------|
| **Flutter SDK** | 3.0.0 or higher |
| **Dart SDK** | 3.0.0 or higher |
| **Minimum Android** | 7.0 (API 24) |
| **Target Android** | 14 (API 34+) |
| **Firebase** | Latest |

---

## 📦 Dependencies

Key packages used in this project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.9.0
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.3.4
  intl: ^0.19.0
  image_picker: ^1.0.7
  url_launcher: ^6.2.0
  file_picker: 10.3.8
  http: ^1.1.0
  path_provider: ^2.1.0
  gal: ^2.3.2
  universal_html: ^2.3.0
  cupertino_icons: ^1.0.6
```

---

## 🔒 Security Notes

This repository does **NOT** contain:

- ❌ `google-services.json` (Firebase config)
- ❌ `key.properties` (signing passwords)
- ❌ `upload-keystore.jks` (signing key)
- ❌ `.env` files (API keys)
- ❌ Build folders (`build/`, `flutter_build/`)
- ❌ `android/` and `ios/` folders (contain secrets)

These files are excluded via `.gitignore` for security.

**To run the app locally**, you need to add these files yourself.

---

## 📱 App Information

| Field | Value |
|-------|-------|
| **App Name** | JWO Welfare System |
| **Package Name** | `com.jalalwelfare.organization` |
| **Version** | 1.0.0 |
| **Platform** | Android (Google Play) |
| **Category** | Lifestyle |
| **Age Rating** | 13+ |

---

## 🏢 About Jalal Welfare Organization

**Jalal Welfare Organization (جلال فلاحی تنظیم)** is a registered welfare organization working for the betterment of communities in Pakistan.

- 📍 **Address:** Village Badalai P/O & Tehsil Wari, District Dir Upper, Pakistan
- 📧 **Email:** [nawabislamic1@gmail.com](mailto:nawabislamic1@gmail.com)
- 📞 **Phone:** +92 341 5566663
- 🌐 **Facebook:** [جلال فلاحی تنظیم](https://www.facebook.com/share/1JE5jerUZF/)
- 📅 **Founded:** December 16, 2019
- 🆔 **Registration No.:** BADALAI

---

## 👨‍💻 Developer

**Nawab Ali**

- 🎓 MPhil Mathematics (Silver Medalist) — Abdul Wali Khan University Mardan
- 🔬 Researcher in Fuzzy Neural Networks & Intelligent Decision-Making
- 📱 Flutter & Firebase Developer
- 📧 [nawabali@awkum.edu.pk](mailto:nawabali@awkum.edu.pk)
- 🔗 [GitHub](https://github.com/nawab-ali45) | [Google Scholar](https://scholar.google.com/citations?user=7FuDaEcAAAAJ&hl=en) | [ORCID](https://orcid.org/0009-0006-4658-7603)

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## ⭐ Support

If you find this project helpful:

- ⭐ Give it a star
- 🐛 Report bugs via [Issues](https://github.com/nawab-ali45/JWO-Flutter-project/issues)
- 📧 Contact us for collaboration

---

<div align="center">

### 💫 *"Serving humanity through technology"*

**© 2026 Jalal Welfare Organization (جلال فلاحی تنظیم)**

All rights reserved.

![Visitors](https://komarev.com/ghpvc/?username=nawab-ali45&color=green&style=flat-square)

</div>
