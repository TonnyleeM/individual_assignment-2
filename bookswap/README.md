# BookSwap

BookSwap is a student-to-student textbook exchange app built with Flutter and Firebase.

## Getting Started

1) Install Flutter and set up an emulator or physical device.

2) Fetch dependencies:

```
flutter pub get
```

3) Firebase setup (development):
- Create a project in the Firebase Console named "BookSwap".
- Add iOS and Android apps, then download and place the platform config files in the native folders.
- Enable Authentication (Email/Password), Firestore, and Storage.

4) Run the app:

```
flutter run
```

This repository follows a layered structure (`models`, `services`, `providers`, `screens`, `widgets`, `utils`).
