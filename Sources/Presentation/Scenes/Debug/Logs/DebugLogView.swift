//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

#if DEBUG

import SwiftUI
import Resolver

// MARK: - Previews
struct DebugLogView: View {
    // MARK: Properties
    @InjectedObject var viewModel: DebugLogViewModel

    // MARK: Body
    var body: some View {
        List {
            Section("List") {
                ForEach(viewModel.logs, id: \.self) { log in
                    ShareLink(
                        item: log,
                        preview: SharePreview(log.name)
                    ) {
                        Text(log.name)
                    }
                }
            }
        }
        .task { await viewModel.appear() }
        .navigationTitle("Logs")
    }
}

#endif
