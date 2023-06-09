# Change Log
Important changes to The Bell will be documented in this file.
The Bell follows [Semantic Versioning](http://semver.org/).
Versions before 1.1.0 are not publicly available.

## [1.1.0](https://github.com/ephread/TheBell/releases/tag/1.1.0) / [1.1.0-rc.4](https://github.com/ephread/TheBell/releases/tag/1.1.0-rc.4)
Released on 2023-05-03.

### Fixed
- Fixed workout recovery during breaks.

## [1.1.0-rc.3](https://github.com/ephread/TheBell/releases/tag/1.1.0-rc.3)
Released on 2023-05-01.

### Fixed
- Restored workout recovery.

## [1.1.0-rc.2](https://github.com/ephread/TheBell/releases/tag/1.1.0-rc.2)
Released on 2023-04-29.

### Fixed
- Ensured the navigation bar is visible after onboarding.
- Clarified audio/haptic feedback conflict.

## [1.1.0-rc.1](https://github.com/ephread/TheBell/releases/tag/1.1.0-rc.1)
Released on 2023-04-29.

### Changed
- Rebuilt the UI from scratch using SwiftUI.
- Repackaged as an App instead of a standalone extension.
- Partially incorporated async/await.

## 1.0.0-rc.5
Released on 2020-07-15.

### Fixed
- Fixed an issue where normal watch sleep would interfere with countdown start.

## 1.0.0-rc.4
Released on 2020-07-14.

### Fixed
- Fixed an issue where view controllers would compete with each other when displaying errors.
- Fixed bound and validation issues for last stretch picker.

## 1.0.0-rc.3
Released on 2020-07-13.

### Changed
- Tweaked crash recovery to discard any old workout when starting a new one.

### Fixed
- Fixed an issue where the wrong energy unit would be used.


## 1.0.0-rc.2
Released on 2020-07-13.

### Fixed
- Fixed a crash recovery issue.
- Fixed a crash occurring at the end of a workout.
- Fixed missing localization strings.
- Prevented tap spamming on certain buttons.

## 1.0.0-rc.1
Released on 2020-07-05.

### Added
- Initial release of The Bell.
