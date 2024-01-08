//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI

struct WorkoutButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

extension ButtonStyle where Self == WorkoutButtonStyle {
    static var workout: Self {
        return Self()
    }
}
