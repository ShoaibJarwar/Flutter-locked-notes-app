# 🔒 Locked Notes App

A Flutter-based secure note-taking application that allows users to create, update, delete, and manage personal notes stored locally using SQLite. The app is designed to provide a simple and secure way to organize private information.

## 🚀 Features

### 📝 Notes Management
- Create Notes
- View Notes
- Edit Notes
- Delete Notes

### 🔍 Search Functionality
- Search notes instantly
- Filter notes by title or content

### 💾 Local Storage
- SQLite database storage
- Persistent data across app sessions

### 🎨 User-Friendly Interface
- Clean and responsive design
- Easy navigation
- Material Design components

---

## 📱 Screens

- Home Screen
- Add Note Screen
- Edit Note Screen
- Note Details Screen

---

## 🏗️ Project Structure

```plaintext
lib/
│
├── models/
│   └── note_model.dart
│
├── services/
│   └── db_helper.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── add_note_screen.dart
│   ├── edit_note_screen.dart
│   └── note_detail_screen.dart
│
└── main.dart
```

---

## 🗄️ Database Schema

### Notes Table

| Column | Type |
|----------|----------|
| id | INTEGER PRIMARY KEY AUTOINCREMENT |
| title | TEXT NOT NULL |
| content | TEXT NOT NULL |
| createdAt | TEXT |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.4.2
  path: ^1.9.1
```

---

## ⚙️ Installation

### Clone Repository

```bash
git clone https://github.com/ShoaibJarwar/Flutter-locked-notes-app
```

### Navigate to Project

```bash
cd locked-notes-app
```

### Install Dependencies

```bash
flutter pub get
```

### Run Application

```bash
flutter run
```

---

## 🎯 Learning Objectives

This project demonstrates:

- Flutter CRUD Operations
- SQLite Database Integration
- Local Data Persistence
- Stateful Widget Management
- Form Validation
- Search Implementation
- Clean Project Structure

---

## 🚀 Future Improvements

- PIN Lock Authentication
- Fingerprint Authentication
- Dark Mode Support
- Categories & Tags
- Cloud Backup
- Note Encryption
- Rich Text Editing
- Export Notes to PDF

---

## 🛠️ Built With

- Flutter
- Dart
- SQLite (sqflite)

---

## 👨‍💻 Author

**Shoaib Akhter**

BS Information Technology Student  
Flutter & Web Development Enthusiast

---

## 📄 License

This project is licensed under the MIT License.