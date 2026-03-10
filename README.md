
# MoveDaily Health Tracker 🏃‍♂️

**MoveDaily** is a SwiftUI fitness tracking app powered by **Apple HealthKit** that visualizes daily activity and weekly health trends including **steps, sleep, and workout minutes**.

The app focuses on **clean architecture, modern Swift concurrency, and production-style UI** while working with real Apple Health data.

Distributed via **Apple TestFlight**.

---

# Screenshots
<img width="645" height="1398" alt="IMG_9312" src="https://github.com/user-attachments/assets/686125ec-fa9e-4233-bd08-7479b33e6651" />


<img width="645" height="1398" alt="IMG_9313" src="https://github.com/user-attachments/assets/0bc2d854-38c9-4f5c-b58b-fffc2ad463ae" />

<img width="645" height="1398" alt="IMG_9324" src="https://github.com/user-attachments/assets/3594f8df-b418-4254-9470-9bd06c1bea25" />


<img width="645" height="1398" alt="IMG_9314" src="https://github.com/user-attachments/assets/30d15273-4dc4-4729-9dcd-932fe58cf360" />


---

# Features

### Health Tracking

* 👟 **Step count** — daily steps fetched from HealthKit
* 😴 **Sleep tracking** — total sleep duration with weekly chart
* 💪 **Workout minutes** — exercise duration with weekly breakdown
* 📊 **7-day charts** — visual trends for steps, sleep and workouts

### Dashboard UI

* 🧩 **Modular activity cards**
* 🔄 **Pull-to-refresh dashboard**
* ⏳ **Loading states**
* ⚠️ **Error overlay with retry**
* 📭 **Empty states when Health data is unavailable**

### Workouts

* 📋 **Recent workout history**
* 🏃 **Workout type detection**
* ⏱️ **Workout duration**
* 🔥 **Calories burned per workout**

### HealthKit Reliability

* Handles **HealthKit error code 11** when data is unavailable
* Safe defaults prevent crashes on new devices

---

# Architecture

```
MoveDaily
├── App
│   └── MoveDailyApp.swift
│
├── HealthKit
│   └── HealthManager.swift
│
├── Models
│   ├── ActivityCardModel.swift
│   ├── DailyStepsModel.swift
│   ├── DailySleep.swift
│   └── WorkoutModel.swift
│
├── ViewModel
│   ├── HomeViewModel.swift
│   └── WorkoutViewModel.swift
│
├── Views
│   ├── HomeView.swift
│   ├── ChartsHomeView.swift
│   ├── ContentView.swift
│   └── LoadingHomeView.swift
│
├── Components
│   ├── FitnessActivityCard.swift
│   └── ProgressCircleView.swift
│
├── SubViews
│   ├── Cards
│   ├── MetricRowView
│   └── SectionHeader
│
├── Enums
│   └── SleepZone.swift
│
└── Errors
    └── AppError.swift
```

---

# Architecture Pattern

**MVVM + Dependency Injection**

* Services injected into ViewModels
* ViewModels expose observable state to SwiftUI views
* HealthKit logic isolated inside a dedicated service

```
View → ViewModel → HealthManager → HealthKit
```

---

# Technical Highlights

## Parallel HealthKit Queries

Health metrics load **simultaneously** using Swift concurrency.

```swift
async let steps = healthManager.fetchSteps()
async let sleep = healthManager.fetchSleep()
async let workouts = healthManager.fetchWorkoutMinutes()

let (stepsData, sleepData, workoutData) =
try await (steps, sleep, workouts)
```

This avoids sequential loading delays.

---

# Callback → async/await Bridge

HealthKit uses callback APIs which are bridged into modern Swift concurrency.

```swift
return try await withCheckedThrowingContinuation { continuation in

    let query = HKStatisticsQuery(...) { _, result, error in

        if let error {
            continuation.resume(throwing: error)
            return
        }

        let value = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
        continuation.resume(returning: value)
    }

    healthStore.execute(query)
}
```

---

# HealthKit Error Handling

HealthKit returns error code **11** when no data exists.

```swift
if let nsError = error as NSError?,
   nsError.domain == "com.apple.healthkit",
   nsError.code == 11 {

    continuation.resume(returning: 0)
    return
}
```

This ensures the app **never crashes on new devices**.

---

# Tech Stack

|              |               |
| ------------ | ------------- |
| Language     | Swift 5.9     |
| UI           | SwiftUI       |
| Architecture | MVVM          |
| Health Data  | HealthKit     |
| Charts       | Swift Charts  |
| State        | `@Observable` |
| Concurrency  | async/await   |

---

# CI / Distribution

The app is distributed via:

**Apple TestFlight**

Production builds are uploaded through **Xcode → Archive → App Store Connect**.

---

# Getting Started

Clone the project:

```bash
git clone https://github.com/rachit-developer24/MoveDaily.git
```

Run on a **real iPhone** because HealthKit is not fully supported on the simulator.

Add these permissions in **Info.plist**

```
NSHealthShareUsageDescription
NSHealthUpdateUsageDescription
```

---

# Roadmap

* Widgets
* Monthly charts
* Step goals
* Dark mode improvements
* App Store release

---

# Author

**Rachit Matolia**
Junior iOS Developer — London

GitHub
[https://github.com/rachit-developer24](https://github.com/rachit-developer24)

LinkedIn
[https://linkedin.com/in/rachit-matolia-085b3b261](https://linkedin.com/in/rachit-matolia-085b3b261)

---

# Portfolio

Other projects

• **CoinTracker** — Crypto price tracker with API pagination
• **Instagram Clone** — Firebase powered social media app

---

