Task Manager App
Overview
Task Manager is a Flutter-based mobile application designed to help users organize and manage tasks efficiently. Built with a clean MVVM (Model-View-ViewModel) architecture, it uses Riverpod for state management and go_router for navigation. The app allows users to create, edit, delete, and filter tasks by priority and category, view task statistics, and customize settings like theme mode.
Features

Task Management:
Create, edit, and delete tasks with title, description, due date (including time), priority, and category.
Mark tasks as complete or incomplete.
View task details with category tags.


Task Filtering:
Search tasks by title or description.
Filter tasks by priority (Low, Medium, High) and category (e.g., Work, Personal, School/Study).


Categories:
Predefined categories: Work (job-related tasks), Personal (errands, family, self-care), School/Study (assignments, exams, projects), Home (cleaning, maintenance, bills), Shopping (groceries, items to buy), Errands (tasks outside the home), Church (church-related activities).
Optional category selection for tasks.


Navigation:
Home screen with buttons to access tasks, statistics, settings, and task creation.
Back navigation from task list, task details, and task form screens.


Settings:
Toggle between light and dark themes.
Clear all tasks with a confirmation dialog.


Persistence:
Tasks and categories are stored locally using SharedPreferences.


Responsive UI:
Clean, user-friendly interface with task cards, search bar, and filter dialog.
Supports date and time selection for task due dates.



Tech Stack

Framework: Flutter
State Management: Riverpod (^2.3.6)
Navigation: go_router (^10.0.0)
Persistence: SharedPreferences (^2.0.15)
Other Libraries: flutter_slidable (^3.0.0), uuid (^3.0.7)
Architecture: MVVM