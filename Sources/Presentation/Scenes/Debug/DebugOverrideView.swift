//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

#if DEBUG

import SwiftUI
import Resolver
import Defaults

// MARK: - Views
struct DebugOverrideView: View {
    // MARK: Private Properties
    @Default(.notifyErrorOnEnd) private var shouldErrorOnEnd
    @Default(.notifyErrorOnPause) private var shouldErrorOnPause
    @Default(.notifyErrorOnSave) private var shouldErrorOnSave
    @Default(.crashOnPause) private var shouldCrashOnPause

    // MARK: Body
    var body: some View {
        List {
            Section {
                Toggle("Error on End", isOn: $shouldErrorOnEnd)
            } header: {
                Text("Errors")
            } footer: {
                Text("Trigger an error when tapping the 'End' button during workouts.")
            }

            Section {
                Toggle("Error on Pause", isOn: $shouldErrorOnPause)
            } footer: {
                Text("Trigger an error when tapping the 'Pause' button during workouts.")
            }

            Section {
                Toggle("Error on Save", isOn: $shouldErrorOnSave)
            } footer: {
                Text("Trigger an error when saving preferences.")
            }

            Section {
                Toggle("Crash on Pause", isOn: $shouldCrashOnPause)
            } header: {
                Text("Crashes")
            }  footer: {
                Text(
                    "Crash when tapping the 'Pause' button during workouts" +
                    "to test the recovery feature."
                )
            }
        }
        .navigationTitle("Overrides")
    }
}

#endif
