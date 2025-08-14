Todo App
A modern, cross-platform Todo application built with Flutter, following the MVVM (Model-View-ViewModel) architecture. The app allows users to manage tasks with due dates, categories, and notifications, providing a clean and accessible user interface. It uses Riverpod for state management and supports both light and dark themes.
Features

Task Management: Create, edit, delete, and mark tasks as complete with smooth animations using AnimatedList.
Due Dates: Set due dates for tasks with reminders scheduled one hour before the due date.
Custom Categories: Add and filter tasks by custom categories (e.g., Work, Personal, Other, or user-defined).
Filtering and Sorting: Filter tasks by status (All, Active, Completed) or category, and sort by creation date, alphabetical order, or due date.
Notifications: Receive local notifications for tasks with due dates (Android and iOS).
Theme Support: Toggle between light and dark themes, persisted across app restarts.
Accessibility: Semantic labels for screen readers to ensure an inclusive experience.
Persistence: Tasks, categories, and preferences are saved using SharedPreferences.

Tech Stack

Framework: Flutter (Dart)
State Management: Riverpod
Architecture: MVVM (Model-View-ViewModel)
Storage: SharedPreferences for persistent data
Notifications: Flutter Local Notifications
Other Packages:
uuid for generating unique task IDs
shared_preferences for data persistence
flutter_local_notifications for scheduling notifications
timezone for handling notification scheduling across time zones



Getting Started
Prerequisites

Flutter SDK: Version 3.0.0 or higher
Dart: Version 2.17.0 or higher
Development Environment: Android Studio, VS Code, or any IDE with Flutter support
Emulator/Device: Android (API 21+) or iOS (12.0+) device/emulator for testing

Installation

Clone the Repository:
git clone https://github.com/Adeyinka-Meduoye/task-manager.git
cd todo_manager


Install Dependencies:Run the following command to install required packages:
flutter pub get


Set Up Android Manifest:Ensure the android/app/src/main/AndroidManifest.xml includes:
<application
    android:enableOnBackInvokedCallback="true"
    ...>

This enables predictive back gestures for Android 13+.

Run the App:Connect a device or emulator and run:
flutter run



Project Structure
todo_app/
├── lib/
│   ├── models/
│   │   └── todo.dart           # Todo model with serialization
│   ├── services/
│   │   ├── notification_service.dart  # Handles local notifications
│   │   └── storage_service.dart       # Manages SharedPreferences
│   ├── viewmodels/
│   │   ├── theme_viewmodel.dart       # Manages theme state
│   │   └── todo_viewmodel.dart        # Manages todo state and logic
│   ├── views/
│   │   ├── screens/
│   │   │   └── home_screen.dart       # Main screen with todo list
│   │   └── widgets/
│   │       └── todo_input.dart        # Input widget for adding todos
│   │       └── todo_item.dart         # Widget for displaying a single todo
│   ├── navigation/
│   │   └── app_router.dart            # Navigation setup (if used)
│   └── main.dart                      # App entry point
├── test/
│   ├── mocks.dart                     # Mock classes for testing
│   ├── viewmodels/
│   │   └── todo_viewmodel_test.dart   # Tests for TodoViewModel
│   └── views/
│       └── screens/
│           └── home_screen_test.dart  # Tests for HomeScreen
├── android/                           # Android-specific configurations
├── ios/                               # iOS-specific configurations
├── pubspec.yaml                       # Dependencies and project config
└── README.md                          # This file

Usage

Add a Todo:

Enter a task title in the input field.
Optionally, set a due date using the "Set Due Date" button.
Optionally, select or add a custom category (e.g., Work, Personal, or a new one).
Tap the "+" button to add the task.


View Todos:

Todos appear in the list below the input field with slide and fade animations.
If todos don’t appear, ensure filters are set to All (for both task status and category).


Filter and Sort:

Use the dropdowns in the filter bar to filter by status (All, Active, Completed) or category (All, Work, Personal, Other, Custom).
Sort tasks by creation date (ascending/descending), alphabetical order, or due date.


Edit or Delete Todos:

Tap a todo to edit its title, due date, or category.
Swipe or use a delete button (if implemented) to remove a todo.


Clear Completed:

Tap the "Clear Completed" button to remove all completed tasks.


Toggle Theme:

Tap the theme icon in the app bar to switch between light and dark modes.



Debugging Tips

Todos Not Visible:

Check the filter bar: Set TodoFilter and CategoryFilter to All.
Add debug prints in TodoViewModel’s filteredTodos getter to inspect the state:print('Filtering todos: state=${state.map((t) => "${t.title}, isCompleted=${t.isCompleted}, category=${t.category}")}');


Verify AnimatedList updates by checking logs from _updateAnimatedList.


Notification Issues:

Ensure flutter_local_notifications is initialized in main.dart.
Test notifications on a physical device, as some emulators may not support them.


UI Issues:

Enable layout debugging:import 'package:flutter/rendering.dart';
void main() {
  debugPaintSizeEnabled = true; // Shows widget boundaries
  // ...
}


Use Flutter DevTools to inspect the widget tree and Riverpod state.


Console Logs:

Check logs for todo creation, filtering, and AnimatedList updates:Added todo: Todo(id: ..., title: Test Todo, isCompleted: false, category: None)
Filtering todos: state=[...]
Updating AnimatedList: isAdded=true, index=...





Testing
Run unit and widget tests to verify functionality:
flutter test

Key tests include:

todo_viewmodel_test.dart: Verifies todo creation, filtering, and sorting logic.
home_screen_test.dart: Ensures the UI renders todos, handles filters, and supports theme toggling.

Known Issues

Todos Not Visible: If the todo list is empty despite a non-zero Total count, check the filter settings or debug filteredTodos in TodoViewModel.
Back Gesture Warning: Fixed by setting android:enableOnBackInvokedCallback="true" in AndroidManifest.xml for Android 13+.

Contributing

Fork the repository.
Create a feature branch (git checkout -b feature/your-feature).
Commit changes (git commit -m "Add your feature").
Push to the branch (git push origin feature/your-feature).
Open a pull request.

License
This project is licensed under the MIT License. See the LICENSE file for details.
Contact
For questions or feedback, contact Adeyinka Meduoye at [yinkopet@gmail.com] or open an issue on GitHub.