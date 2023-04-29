//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI

/// Custom fonts used by The Bell.
enum BellFont: Int {
    case title
    case time
    case time2
    case metric
    case unit
    case caption

    var isUsingSmallCaps: Bool {
        switch self {
        case .unit: return true
        default: return false
        }
    }

    var leading: Font.Leading {
        switch self {
        case .time2: return .tight
        default: return .standard
        }
    }

    var weight: Font.Weight {
        switch self {
        case .title: return .regular

        case .time: return .regular
        case .time2: return .regular

        case .metric: return .regular

        case .unit: return .semibold

        default: return .regular
        }
    }

    var baseSize: CGFloat {
        switch self {
        case .title: return 13

        case .time: return 40
        case .time2, .unit: return 30

        case .metric: return 30
        case .caption: return 16
        }
    }
}

// MARK: View & Modifier extensions

// It's a bit frustrating that Apple doesn't provide a way to create
// a custom font that both scales and uses the system font. We are
// repurposing some old iOS 13 / watchOS 6 code here.
struct BellFontViewModifier: ViewModifier {
    // MARK: Properties
    var font: BellFont

    // MARK: Private Bindings
    @Environment(\.sizeCategory) private var sizeCategory

    // MARK: Body
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: font.baseSize)
        var suiFont = Font.system(size: scaledSize, design: .rounded).leading(font.leading)

        if font.isUsingSmallCaps {
            suiFont = suiFont.smallCaps()
        }

        return content
            .font(suiFont)
            .fontWeight(font.weight)
    }
}

extension View {
    func bellFont(_ font: BellFont) -> some View {
        return self.modifier(BellFontViewModifier(font: font))
    }
}

extension Text {
    func bellFont(_ font: BellFont) -> some View {
        return self.modifier(BellFontViewModifier(font: font))
    }
}
