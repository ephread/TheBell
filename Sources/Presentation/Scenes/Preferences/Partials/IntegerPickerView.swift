//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI

struct IntegerPickerView: View {
    @Binding var selectedValue: Int
    let range: ClosedRange<Int>
    let unit: String?
    let label: String
    let shortLabel: String?

    private var detailLabel: String {
        if let unit = unit {
            return "\(selectedValue) \(unit)"
        } else {
            return "\(selectedValue)"
        }
    }

    var body: some View {
        NavigationLink {
            HStack(spacing: 15) {
                Spacer()

                Picker("", selection: $selectedValue) {
                    ForEach(Array(range), id: \.self) { value in
                        Text("\(value)")
                    }
                }
                .accessibilityIdentifier("Preferences_IntegerPicker")
                .pickerStyle(.inline)
                .labelsHidden()
                .frame(width: 60, height: 100)

                if let unit = unit {
                    Text(unit)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer()
            }
            .navigationTitle(shortLabel ?? label)
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            VStack(alignment: .leading) {
                Text(label)
                Text(detailLabel)
                    .accessibilityIdentifier("Preferences_IntegerPicker_DetailLabel")
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
            }
        }
    }
}

struct IntegerPickerPreview: View {
    @State var selectedValue: Int = 90
    let range = 60...200

    var body: some View {
        NavigationStack {
            List {
                IntegerPickerView(
                    selectedValue: $selectedValue,
                    range: range,
                    unit: "BPM",
                    label: "Maximum Heart Rate",
                    shortLabel: "Max Heart Rate"
                )
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG

struct IntegerPickerView_Previews: PreviewProvider {
    @State static var selectedValue: Int = 90
    static let range = 60...200

    static var previews: some View {
        Group {
            IntegerPickerPreview()
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"))
                .previewDisplayName("Series 6 - 40mm")

            IntegerPickerPreview()
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
                .previewDisplayName("Series 7 - 45mm")
        }
    }
}

#endif
