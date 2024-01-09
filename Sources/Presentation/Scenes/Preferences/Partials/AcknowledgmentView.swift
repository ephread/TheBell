//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import UIKit
import SwiftUI

struct AcknowledgmentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Acknowledgement.Grdb.name)
                        .font(.body)
                        .fontWeight(.semibold)
                    Text(L10n.Acknowledgement.Grdb.license)
                        .font(.footnote)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Acknowledgement.Resolver.name)
                        .font(.body)
                        .fontWeight(.semibold)
                    Text(L10n.Acknowledgement.Resolver.license)
                        .font(.footnote)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Acknowledgement.Defaults.name)
                        .font(.body)
                        .fontWeight(.semibold)
                    Text(L10n.Acknowledgement.Defaults.license)
                        .font(.footnote)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Acknowledgement.Puppy.name)
                        .font(.body)
                        .fontWeight(.semibold)
                    Text(L10n.Acknowledgement.Puppy.license)
                        .font(.footnote)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Acknowledgement.Swiftlog.name)
                        .font(.body)
                        .fontWeight(.semibold)
                    Text(L10n.Acknowledgement.Swiftlog.license)
                        .font(.footnote)
                }
            }
        }
        .accessibilityIdentifier("Preferences_FinaleStageDuration_ScrollView")
        .navigationTitle(L10n.Preference.acknowledgement)
        .foregroundStyle(Color.white.opacity(0.6))
    }
}

#if DEBUG

struct AcknowledgmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AcknowledgmentView()
        }
    }
}

#endif
