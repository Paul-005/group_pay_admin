# GroupPay Admin

A Flutter application for managing group payments.


## Overview

GroupPay Admin is a Flutter-based admin panel designed to streamline the process of managing group payments. It allows administrators to create payment requests, track student payments, manage student lists, and monitor overall collection progress.

## Features

- **Dashboard:** Provides a high-level overview of active payment requests, collection progress, and key statistics.
- **Post Management:** Create, view, and manage payment requests (referred to as "posts").
- **Student Management:**
  - Accept or reject student requests to join the group.
  - View a list of accepted students.
  - Remove students from the group.
- **Payment Tracking:** Monitor payment progress, view paid and unpaid students, and track individual student payments.
- **Profile Management:** Allows administrators to manage their profile information and update bank/UPI details.
- **Notifications:** (Future Enhancement) Implement a notification system for payment reminders and updates.

## Getting Started

### Prerequisites

- Flutter SDK installed on your machine.
- Firebase project set up with Firestore enabled.

### Installation

1.  Clone the repository:

    ```bash
    git clone <repository_url>
    ```

2.  Navigate to the project directory:

    ```bash
    cd group_pay_admin
    ```

3.  Install dependencies:

    ```bash
    flutter pub get
    ```

4.  Configure Firebase:
    - Download your `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) file(s) from your Firebase project.
    - Place them in the appropriate directories within your Flutter project (usually `android/app/` and `ios/Runner/`).
5.  Update Firebase configuration in `main.dart`:

    - Ensure Firebase is initialized in your `main.dart` file:

    ```dart
    import 'package:firebase_core/firebase_core.dart';
    import 'firebase_options.dart'; // Create this file

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(MyApp());
    }
    ```

    - Create `lib/firebase_options.dart` using the FlutterFire CLI:

    ```bash
    dart pub global activate flutterfire_cli
    flutterfire configure # Follow the prompts
    ```

### Running the App

```bash
flutter run
```

## Key Components

- **`lib/dashboard/dashboard.screen.dart`:** The main dashboard screen displaying payment progress and post summaries.
- **`lib/dashboard/post.dart`:** Screen for creating new payment requests ("posts").
- **`lib/dashboard/manage_post.screen.dart`:** Screen for viewing details and managing a specific payment request.
- **`lib/manage/student_list.dart`:** Screen for managing student requests and the list of accepted students.
- **`lib/auth/signup_page.dart`:** Screen for admin signup, including admin code generation.
- **`lib/settings/profile.screen.dart`:** Screen for viewing admin profile.
- **`lib/models/student.dart`:** (Example - you might want to create a dedicated model) Defines the `Student` data structure.

## Data Model (Firestore)

- **`admin` Collection:** Stores administrator data, including:
  - `adminCode`: Unique code for the admin's group.
  - `bank_upi`: Bank/UPI details for receiving payments.
  - `students`: List of accepted students (email, UID).
  - `student_requests`: List of pending student requests.
- **`groups` Collection:** Stores group information:
  - `admin`: UID of the administrator.
  - `students`: List of student UIDs.
  - `posts`: List of post IDs associated with the group.
- **`posts` Collection:** Stores payment request details:
  - `postId`: Unique ID for the post.
  - `title`: Title of the payment request.
  - `description`: Description of the payment request.
  - `amount`: Amount to be paid per student.
  - `lastDate`: Due date for the payment.
  - `paid`: List of student UIDs who have paid.
  - `unpaid`: List of student UIDs who have not paid.
  - `no_of_students`: Total number of students in the group.
