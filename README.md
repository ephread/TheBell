# ![The Bell](Documentation/git_banner.png)

<div align="center">
<p>A timer app designed for high-intensity interval workouts.</p>
<a href="https://apps.apple.com/us/app/apple-store/id1522205874">
<img src="Documentation/download_on_the_app_store.svg" alt="Download on the App Store" />
</a>
</div>

## Table of Content

- [Table of Content](#table-of-content)
- [History](#history)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Installation](#installation)
- [Architecture \& Rational](#architecture--rational)
  - [Overview](#overview)
  - [Tiers and naming conventions](#tiers-and-naming-conventions)
  - [Navigation](#navigation)
  - [Why do audio assets sound silly?](#why-do-audio-assets-sound-silly)
  - [Future](#future)
- [License](#license)

## History

During the 2020 lockdowns, I created The Bell app as a way to further explore watchOS development. Initially built using WatchKit, I later discovered that newer APIs were SwiftUI-only after the release of the Apple Watch Series 7.

In early 2023, I decided to revisit the app and update it by transitioning the UI layer to SwiftUI and implementing async/await APIs. With no intention of monetizing it, I chose to open-source The Bell as a functional proof-of-concept.

Throughout the process, I reworked approximately 70% of the app's codebase. Looking back, if I were to start from scratch today, I would likely opt for an Elm/redux-inspired architecture over MVVM.

## Getting Started

### Requirements

- Xcode 14.3+
- watchOS 9.4+

### Installation

1. Clone the repository.
2. (Optional) Install [Mint] and ensure it's available in the `PATH` loaded by Xcode.
   - Run `mint bootstrap`
3. Copy `main.xcconfig.example` and rename it to `main.xcconfig`
   - In `main.xccconfig`, set `DEVELOPMENT_TEAM` to a valid identifier and `DISAMBIGUATOR` to `${DEVELOPMENT_TEAM}`.
   - Alternatively, if you plan to run the app on the simulator, you can leave
     `DEVELOPMENT_TEAM` and `DISAMBIGUATOR` blank.
4. Copy the content of `Supporting Files/Assets/Sounds/cc0` to `Supporting Files/Assets/Sounds/`, see [Audio Assets] for more information.
5. Open Xcode and run the project!

[Mint]: https://github.com/yonaskolb/Mint
[Audio Assets]: #why-do-audio-assets-sound-silly

## Architecture & Rational

### Overview

The Bell uses a three-tier architecture with MVVM in the presentation layer. While the layers are not completely separated, they could be easily decoupled with minimal work. For example:

1. the simplicity of the data model in The Bell allows for the presentation layer to directly query repositories, as the data is often not converted or manipulated by the application layer;
2. `UserPreference` and `Workout` are both plain structs, easily created and mocked and thus not abstracted;
3. application-level data models like `WorkoutSummary` are also freely passed around.

However, a more complex app would benefit from having different types encapsulating the data in the different layers, even if they match 1:1 (in that case, type aliases could be used).

The Bell relies heavily on protocols and dependency injection to ensure that view models, managers, and helpers can be tested in isolation.

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

The audio assets used in the App Store version of the app cannot be freely distributed, so I had to replace them with public domain equivalents. I intentionally chose some silly sounds to keep things fun and lighthearted. Who knew that public-domain audio could be so fun?

### Future

Here are some tasks that I plan to work on for The Bell as time allows.

- [ ] Improve the test structure and split test cases between unit and integration tests,
      especially around time-sensitive code.
- [ ] Save the workout state in the database instead of using UserDefaults,
      as this is a remnant of early prototypes.
- [ ] Allow the creation and management of multiple workouts.

## License

The codebase is licensed under the terms of the Apache License 2.0, see [LICENSE]
for more information. It includes code inspired by DebouncedOnChange,
licensed under the terms of the MIT license.

Image assets are licensed under the terms of the Creative Commons
Attribution-NonCommercial-NoDerivatives 4.0 International License, see [LICENSE.CC-BY-NC-ND]
for more information.

Audio assets are licensed under terms of the Creative Commons CC0 1.0 Universal License,
see [LICENSE.CC0]. They were sourced from freesound.org and remixed:

- [sheepbone flute] by [magnuswaker]
- [Loony & Wacky » Boing 1] by [Hedmarking]

[LICENSE]: LICENSE
[LICENSE.CC-BY-NC-ND]: LICENSE.CC-BY-NC-ND
[LICENSE.CC0]: LICENSE.CC0

[DebouncedOnChange]: https://github.com/Tunous/DebouncedOnChange

[freesound.org]: https://freesound.org/

[sheepbone flute]: https://freesound.org/people/Hedmarking/sounds/179061/
[Loony & Wacky » Boing 1]: https://freesound.org/people/magnuswaker/sounds/540788/

[magnuswaker]: https://freesound.org/people/magnuswaker/
[Hedmarking]: https://freesound.org/people/Hedmarking/
