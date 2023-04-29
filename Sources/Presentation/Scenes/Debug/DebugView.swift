//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

#if DEBUG

import SwiftUI
import Resolver
import Puppy

// MARK: - Views
/// Simple debug menu.
struct DebugView: View {

    // MARK: Body
    var body: some View {
        List {
            Section {
                NavigationLink {
                    DebugLogView()
                } label: {
                    Label("Show logs", systemImage: "doc.plaintext")
                }
            } footer: {
                Text("Export logs through the standard export sheets.")
            }

            Section {
                NavigationLink {
                    DebugOverrideView()
                } label: {
                    Label("Set overrides", systemImage: "gearshape")
                }
            } footer: {
                Text("Override actions to trigger specific behaviors during development.")
            }
        }
        .navigationTitle("Debug Menu")
    }
}

// MARK: - Previews
struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DebugView()
                .navigationTitle("Debug Menu")
        }
    }
}

#endif
