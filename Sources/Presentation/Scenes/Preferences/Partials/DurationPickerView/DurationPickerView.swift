//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import SwiftUI

struct DurationPickerView: View {
    // MARK: - Private States
    @Binding var minutes: Int
    @Binding var seconds: Int

    // MARK: - Private Properties
    let range: ClosedRange<Int>
    let minuteStep: Int
    let secondStep: Int

    let label: String
    let hint: String

    var secondOptions: [Int] {
        helper.makeSecondOptions(range: range, step: secondStep)
    }

    var minuteOptions: [Int] {
        helper.makeMinuteOptions(range: range, step: minuteStep)
    }

    // MARK: - Initialization
    private let helper = DurationPickerViewHelper()

    private var detailLabel: String {
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    var body: some View {
        NavigationLink {
            GeometryReader { proxy in
                VStack {
                    Spacer()

                    VStack(spacing: 15) {
                        VStack {
                            captions(proxy: proxy)
                            pickers(proxy: proxy)
                        }

                        Text(hint)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            // It's unclear why .fixedSize is required on watchOS, while
                            // .lineLimit is enough on iOS.
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(label)
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            VStack(alignment: .leading) {
                Text(label)
                Text(detailLabel)
                    .font(.caption2)
                    .foregroundColor(Color.secondary)
            }
        }
    }

    // MARK: Private Builders
    @ViewBuilder
    private func captions(proxy: GeometryProxy) -> some View {
        HStack(spacing: 15) {
            Spacer()

            Text("Minutes")
                .font(.footnote)
                .fixedSize(horizontal: true, vertical: true)
                .minimumScaleFactor(0.5)
                .frame(width: proxy.size.width / 3.5)

            Text(":")
                .frame(width: 5)
                .opacity(0)

            Text("Seconds")
                .font(.footnote)
                .fixedSize(horizontal: true, vertical: true)
                .minimumScaleFactor(0.5)
                .frame(width: proxy.size.width / 3.5)

            Spacer()
        }
    }

    @ViewBuilder
    private func pickers(proxy: GeometryProxy) -> some View {
        HStack(spacing: 15) {
            Spacer()

            Picker("Minutes", selection: $minutes) {
                ForEach(minuteOptions, id: \.self) { value in
                    Text("\(value)")
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
            .onChange(of: minutes, debounceTime: 0.5) { _ in
                validateValue()
            }
            .frame(width: proxy.size.width / 3.5, height: proxy.size.height / 2)
            .accessibilityIdentifier("Preferences_Duration_MinutePicker")

            Text(":")
                .frame(width: 5)

            Picker("Seconds", selection: $seconds) {
                ForEach(secondOptions, id: \.self) { value in
                    Text("\(value)")
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
            .onChange(of: seconds, debounceTime: 0.5) { _ in
                validateValue()
            }
            .frame(width: proxy.size.width / 3.5, height: proxy.size.height / 2)
            .accessibilityIdentifier("Preferences_Duration_SecondPicker")

            Spacer()
        }
    }

    // MARK: Private Methods
    private func validateValue() {
        let components = helper.validateAndUpdateTimeComponents(
            range: range,
            minutes: minutes,
            seconds: seconds
        )

        if let components {
            minutes = components.minutes
            seconds = components.seconds
        }
    }
}

struct DurationPickerPreview: View {
    @State var minutes: Int = 1
    @State var seconds: Int = 15

    var body: some View {
        NavigationStack {
            List {
                DurationPickerView(
                    minutes: $minutes,
                    seconds: $seconds,
                    range: 10...900,
                    minuteStep: 1,
                    secondStep: 5,
                    label: "Round duration",
                    hint: "Between 10 seconds and 15 minutes"
                )
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DurationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DurationPickerPreview()
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"))
                .previewDisplayName("Series 6 - 40mm")

            DurationPickerPreview()
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
                .previewDisplayName("Series 7 - 45mm")
        }
    }
}
