Here you go — copy everything below:

---

# MoveDaily 🏃

A production-style iOS fitness tracking app built with SwiftUI and HealthKit, displaying daily activity rings, step count, calories, exercise minutes, stand hours, and weekly workout breakdowns — all powered by real Apple Health data.

---

## Screenshots

<img width="832" height="843" alt="Screenshot 2026-02-19 at 02 57 42" src="https://github.com/user-attachments/assets/c14c8d4c-5c60-4405-a765-6ffa981af619" />
<img width="731" height="872" alt="Screenshot 2026-02-19 at 02 18 08" src="https://github.com/user-attachments/assets/4c59ea38-d0b1-4b79-9c09-a9e509d901b1" />
<img width="708" height="860" alt="Screenshot 2026-02-19 at 02 16 44" src="https://github.com/user-attachments/assets/790a73b1-628c-46dd-a45a-8c6cf6d3cd33" />


---

## Features

- 🔴🟢🔵 **Activity rings** — animated tri-ring progress view mirroring Apple's Activity app
- 👟 **Step count** — daily steps fetched live from HealthKit
- 🔥 **Calories burned** — active energy from HealthKit
- ⏱️ **Exercise minutes** — Apple exercise time metric
- 🧍 **Stand hours** — stand hour count for the day
- 💪 **Weekly workout breakdown** — minutes per workout type (running, cycling, strength, soccer) from `HKWorkout`
- 📋 **Recent workouts list** — scrollable workout history with duration and calories
- ✅ **Graceful no-data handling** — HealthKit error code 11 handled across all queries, no crashes on fresh devices

---

## Architecture

```
MoveDaily/
├── Models/
│   ├── ActivityCard.swift
│   └── WorkoutModel.swift
├── Services/
│   └── HealthManager.swift        # All HealthKit queries
├── ViewModels/
│   ├── HomeViewModel.swift        # @Observable, parallel fetching
│   └── WorkoutViewModel.swift
├── Views/
│   ├── HomeView.swift
│   ├── ProgressCircleView.swift   # Animated ring component
│   ├── FitnessActivityCard.swift
│   ├── WorkoutCard.swift
│   └── MoveDailyMainTabView.swift
└── App/
    └── MoveDailyApp.swift
```

**Pattern:** MVVM · `@Observable` · `async/await` · `async let` parallel fetching

---

## Technical Highlights

### Parallel HealthKit Fetching
```swift
async let calories = healthManager.fetchCaloriesBurned()
async let active   = healthManager.fetchExerciseTime()
async let stand    = healthManager.fetchTodayStandHours()
async let steps    = healthManager.fetchStepCount()

let (cals, activeInt, standInt, stepsInt) = try await (calories, active, stand, steps)
```
All four metrics fetch simultaneously — no sequential waiting.

### Callback → async/await Bridge
```swift
return try await withCheckedThrowingContinuation { continuation in
    let query = HKStatisticsQuery(...)  { _, results, error in
        if let error { continuation.resume(throwing: error); return }
        continuation.resume(returning: results?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
    }
    healthStore.execute(query)
}
```
All HKQuery callbacks are cleanly wrapped in `withCheckedThrowingContinuation`.

### HealthKit Error Code 11 Handling
```swift
if let nsError = error as NSError?,
   nsError.domain == "com.apple.healthkit",
   nsError.code == 11 {
    continuation.resume(returning: 0) // No data available — safe default
    return
}
```
Prevents crashes on simulators and devices with no health data.

---

## HealthKit Permissions

The app requests read-only access to:

| Metric | HKType |
|--------|--------|
| Active calories | `HKQuantityType(.activeEnergyBurned)` |
| Exercise time | `HKQuantityType(.appleExerciseTime)` |
| Stand hours | `HKCategoryType(.appleStandHour)` |
| Step count | `HKQuantityType(.stepCount)` |
| Workouts | `HKObjectType.workoutType()` |

---

## Tech Stack

| | |
|---|---|
| **Language** | Swift 5.9 |
| **UI** | SwiftUI |
| **Architecture** | MVVM |
| **Health Data** | HealthKit |
| **State** | `@Observable` |
| **Concurrency** | async/await · async let |

---

## Getting Started

```bash
git clone https://github.com/rachit-developer24/MoveDaily.git
```

Open in Xcode and run on a **real device** — HealthKit is not fully supported on simulator.

> Make sure to add `NSHealthShareUsageDescription` to your Info.plist before running.

---

## Roadmap

- [ ] App Store release
- [ ] Charts view with weekly/monthly history
- [ ] Step count goal customisation
- [ ] Widget support

---

## Author

**Rachit Matolia** — Junior iOS Developer, London
[GitHub](https://github.com/rachit-developer24) · [LinkedIn](https://linkedin.com/in/rachit-matolia-085b3b261)
