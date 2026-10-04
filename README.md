# Futblha

**Futblha** is a comprehensive Flutter application designed to revolutionize how football enthusiasts organize and participate in games. It facilitates the management of "Diwaniyat" (gatherings), game scheduling, playground bookings, and social interactions among players.

## 📱 Features

The application offers a wide range of features to enhance the football community experience:

- **Authentication & User Management**: Secure Login, Registration, Password Recovery, and comprehensive Profile management.
- **Diwaniyat (Gatherings)**: Create, join, and manage football groups and gatherings.
- **Games & Scheduling**: Organize matches, invite players, and track schedules.
- **Playgrounds & Bookings**: Browse available playgrounds, view details, and make bookings.
- **Wallet & Payments**: Integrated wallet system for managing funds and multiple payment methods.
- **Chat System**: Real-time communication between players and groups.
- **Social Integration**: Notification system, Rankings, and Social Media sharing.
- **Support & Settings**: FAQ, Customer Support, and customizable app settings.
- **Localization**: Full support for **Arabic** and **English** languages.
- **Theming**: Dynamic Light and Dark mode support.

## 🛠 Tech Stack & Architecture

Futblha is built using **Flutter** and follows **Clean Architecture** principles to ensure scalability, testability, and maintainability.

- **Language**: Dart
- **Framework**: Flutter (SDK ^3.10.0)
- **Architecture**: Clean Architecture (Presentation, Domain, Data, Application layers)

### Key Libraries & Packages

- **State Management**: `flutter_bloc`
- **Dependency Injection**: `get_it`, `injectable`
- **Routing**: `auto_route`
- **Networking**: `dio`, `pretty_dio_logger`
- **Data Class / Unions**: `freezed`, `json_serializable`, `equatable`
- **Localization**: `easy_localization`
- **Local Storage**: `shared_preferences`, `hive_flutter`
- **Firebase**: `firebase_core`, `firebase_messaging` (Push Notifications)
- **Real-time Updates**: `pusher_channels_flutter`
- **UI Components**: `flutter_svg`, `cached_network_image`, `auto_size_text`, `flutter_slidable`, `pin_code_fields`
- **Utils**: `permission_handler`, `url_launcher`, `device_info_plus`, `connectivity_plus`

## 📂 Project Structure

The project is organized into four main layers:

```
lib/
├── application/       # Application configuration, core utilities, DI, theme, and router
├── data/              # Data layer: Datasources, DTOs (Models), and Repository implementations
├── domain/            # Domain layer: Entities, Repository interfaces (Business Logic)
├── presentation/      # UI layer: Pages, Widgets, and State Management (Blocs)
├── generated/         # Generated files (assets, localization keys)
└── utils/             # General utility functions
```

## 🚀 Getting Started

Follow these steps to set up the project locally.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- An IDE (VS Code or Android Studio) with Flutter extensions.
- Git.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-repo/futblha.git
    cd futblha
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Generate Code:**
    This project uses code generation for DI, routing, and JSON serialization. Run the following command:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the App:**
    ```bash
    flutter run
    ```

### Localization

The app uses `easy_localization`. Translation files are located in `assets/l10n/`.
Supported locales:
- English (`en`)
- Arabic (`ar`)

## 🎨 Assets & Fonts

- **Images**: Stored in `assets/img/`
- **Fonts**: Custom fonts (SF Arabic) located in `assets/fonts/`

## 🤝 Contributing

1.  Fork the project
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

