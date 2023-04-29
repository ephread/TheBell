//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI

struct WorkoutControlButtonStyle: ButtonStyle {
    // MARK: Properties
    var backgroundColor: Color

    // MARK: Body
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect()
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.8 : 1))
            .cornerRadius(25)
    }
}

extension ButtonStyle where Self == WorkoutControlButtonStyle {
    /// A button style used for buttons
    /// that stop/pause/resume a workout.
    static func workoutControl(color: Color) -> Self {
        return Self(backgroundColor: color)
    }
}
