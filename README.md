# ![The Bell](Documentation/git_banner.png)

A round-based HIIT timer for Apple Watch.

## Table of Content

- [Table of Content](#table-of-content)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Architecture \& Rational](#architecture--rational)
  - [Why do audio assets sound silly?](#why-do-audio-assets-sound-silly)
- [History and Future](#history-and-future)
- [License](#license)

## History

I first developed The Bell during the 2020 lockdowns to further familiarise myself with watchOS. The first version used WatchKit; when Apple released the Apple Watch Series 7, it became clear that WatchKit was no longer the preferred toolkit as some new APIs were SwiftUI-only.

In early 2023, I revisited the App by converting the UI layer to SwiftUI and moving to the async/await APIs. Since I never intended The Bell to be anything more than a functional proof of concept, I decided to open-source it.

I reworked about 70% of the app. If I had to start it from scratch today, I would probably use an Elm/redux-inspired architecture instead of MVVM.

## Getting Started

### Requirements

- Xcode 14.3+
- WatchOS 9.4+

### Installation

1. Clone the repository.
2. (Optional) Install [Mint] and ensure it's available in the `PATH` loaded by Xcode.
   - Run `mint bootstrap`
3. Copy `main.xcconfig.example` and rename it to `main.xcconfig`
   - In `main.xccconfig`, set `DEVELOPMENT_TEAM` to a valid identifier.
   - Alternatively, if you plan to run the app on the simulator, you can leave
     `DEVELOPMENT_TEAM` blank and set `DISAMBIGUATOR` to a random string.
4. Copy the content of `Supporting Files/Assets/Sounds/cc0` to `Supporting Files/Assets/Sounds/`, see [Audio Assets] for more information.
5. Open Xcode and run the project!

[Mint]: https://github.com/yonaskolb/Mint
[Audio Assets]: #why-do-audio-assets-sound-silly

## Architecture & Rational

### Overview

The Bell uses a three-tier architecture with MVVM in the presentation layer. To keep things simple, layers are not entirely decoupled from each other (but could become so with minimal work). For example:

1. since the data model is simple and often not converted/manipulated by the application layer, the presentation layer can query repositories directly;
2. `UserPreference` and `Workout` are plain structs that can be easily created/mocked and are thus not abstracted.
3. Application-level data models like `WorkoutSummary` are also freely passed around.

However, a more complex app would benefit from having different types encapsulating the data in the different layers, even if they match 1:1 (in that case, type aliases could be used).

The Bell relies heavily on protocols and dependency injection to make view models, managers and helpers testable in isolation.

### Tiers and naming conventions

- **Presentation Layer:** Contains all the UI-related code, including MVVM's Views and View Models.
    - _Standard suffixes:_ `-View` (suffixes `Button`, `Label` etc. are also possible), `-ViewModel`
    - _Directory:_ `Sources/Presentation`
- **Application Layer:** Contains the application logic and abstractions to system components, such as HealthKit, AVFoundation and Haptic Feedback. HealthKit can be considered part of MVVM's Models.
    - _Standard suffixes:_ `-Manager`
    - _Directory:_ `Sources/Application`
- **Data Layer:** Contains repositories and the database logic, aka MVVM's Models.
    - _Standard suffixes:_ `-Repository`
    - _Directory:_ `Sources/Data`

All tiers may also contain `-Helper` types.

### Navigation

The Bell has a very simple navigation pattern, therefore, `NavigationPath` and/or Coordinators are not involved.

### Why do audio assets sound silly?

The App Store version uses audio assets that can't be freely distributed. Therefore, they have been replaced by public domain equivalents. Yes, they sound silly.

## License

The codebase is licensed under the terms of the Apache License 2.0, see [LICENSE.APACHE]
for more information.

Image assets are licensed under the terms of the Creative Commons
Attribution-NonCommercial-NoDerivatives 4.0 International License, see [LICENSE.CC-BY-NC-ND]
for more information.

Audio assets are licensed under terms of the Creative Commons CC0 1.0 Universal License. They were
sourced from freesound.org and remixed:

- [sheepbone flute] by [magnuswaker]
- [Loony & Wacky » Boing 1] by [Hedmarking]

[LICENSE.APACHE]: ./Licenses/LICENSE.APACHE
[LICENSE.CC-BY-NC-ND]: ./Licenses/LICENSE.CC-BY-NC-ND
[freesound.org]: https://freesound.org/

[sheepbone flute]: https://freesound.org/people/Hedmarking/sounds/179061/
[Loony & Wacky » Boing 1]: https://freesound.org/people/magnuswaker/sounds/540788/

[magnuswaker]: https://freesound.org/people/magnuswaker/
[Hedmarking]: https://freesound.org/people/Hedmarking/
