//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import HealthKit

// In HealthKit documentation Apple mentions that: "In general, you can
// use HealthKit safely in a multithreaded environment."
//
// https://developer.apple.com/documentation/healthkit/about_the_healthkit_framework
//
// While its type are not sendable, I'm confident they will conform once
// Swift 6 comes out.

// HKWorkoutSession and HKWorkoutSession are considered thread-safe.
extension HKLiveWorkoutBuilder: @unchecked Sendable { }
extension HKWorkoutSession: @unchecked Sendable { }

// HKObjectType and HKSampleType are immutable.
extension HKSampleType: @unchecked Sendable { }
extension HKObjectType: @unchecked Sendable { }

// HKWorkout manages its own internal state and offers read-only APIs.
extension HKWorkout: @unchecked Sendable { }

// HKUnit is immutable.
extension HKUnit: @unchecked Sendable { }
