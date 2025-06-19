# EKG Vision - Doctor Authentication System

EKG Vision is a Flutter application for doctors to view and analyze EKG data. This system includes a secure authentication system for doctors and a modern, user-friendly interface.

## Features

- Doctor registration with username, email, and password
- Secure login system
- Persistent session management
- EKG scan upload and analysis
- Patient management
- Modern UI with light/dark mode
- Profile and settings management

## Project Structure

- `/lib` - Flutter app source code
- `/backend` - Python Flask backend service
- `/gallery/light` - UI screenshots (for documentation)

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Python 3.8+
- pip (Python package manager)

---

## UI Pages Overview

### 1. Splash Screen
The splash screen welcomes users with the app logo and transitions to login or home based on authentication status.

![Splash Screen](gallery/light/entrance/Screenshot%20from%202025-06-03%2016-29-58.png)

---

### 2. Login & Register
Doctors can securely log in or register. Registration requires username, email, and password. Both forms provide validation and error feedback.

**Login:**
![Login](gallery/light/entrance/Screenshot%20from%202025-06-03%2016-16-52.png)


**Register:**
![Register](gallery/light/entrance/Screenshot%20from%202025-06-03%2016-17-02.png)

---

### 3. Dashboard (Scanning)
The dashboard allows doctors to select a patient, choose a model, and upload or capture an EKG image for analysis. Results are displayed with annotated images and detection details.

![Dashboard 1](gallery/light/scan/Screenshot%20from%202025-06-03%2016-49-10.png)
![Dashboard 2](gallery/light/scan/Screenshot%20from%202025-06-03%2016-49-34.png)

---

### 4. Analysis
The analysis page lists all previous EKG scans, searchable by patient username. Each entry shows scan date, time, and summary. Tapping an entry opens detailed results.

![Analysis 1](gallery/light/analysis/Screenshot%20from%202025-06-03%2016-50-00.png)
![Analysis 2](gallery/light/analysis/Screenshot%20from%202025-06-03%2016-50-13.png)

---

### 5. Scan Detail
Detailed view of a selected scan, including the EKG image, patient info, model used, and detection results.

![Scan Detail 1](gallery/light/scan-detail/Screenshot%20from%202025-06-03%2016-50-27.png)
![Scan Detail 2](gallery/light/scan-detail/Screenshot%20from%202025-06-03%2016-50-39.png)

---

### 6. Profile
Doctors can view and update their profile, upload a profile picture, access login history, and navigate to About or Privacy Policy.

![Settings 1](gallery/light/settings/Screenshot%20from%202025-06-03%2016-50-50.png)
![Settings 2](gallery/light/settings/Screenshot%20from%202025-06-03%2016-50-58.png)
---

### 7. Settings
Settings allow users to toggle dark mode, change password, and update email. All actions are accessible from a single page.

![Settings 3](gallery/light/settings/Screenshot%20from%202025-06-03%2016-51-55.png)
![Settings 4](gallery/light/settings/Screenshot%20from%202025-06-03%2016-52-01.png)
![Settings 5](gallery/light/settings/Screenshot%20from%202025-06-03%2016-52-15.png)
![Settings 6](gallery/light/settings/Screenshot%20from%202025-06-03%2016-52-27.png)
![Settings 7](gallery/light/settings/Screenshot%20from%202025-06-03%2016-52-50.png)

---

## Notes
- All screenshots are from the light theme. For dark mode, see the `gallery/dark` directory.
- For backend setup and API details, see `/backend/README.md`.

---

© 2025 EKG Vision. All rights reserved.
