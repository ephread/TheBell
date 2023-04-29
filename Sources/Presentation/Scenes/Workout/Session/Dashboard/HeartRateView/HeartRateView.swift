//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI

// MARK: - Views
struct HeartRateView: View {
    @ObservedObject var viewModel: HeartRateViewModel

    var body: some View {
        Image(viewModel.currentIconName)
            .resizable()
    }
}

// MARK: - Previews
struct HeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView(viewModel: HeartRateViewModel())
            .frame(width: 20, height: 20, alignment: .center)

        HeartRateView(viewModel: HeartRateViewModel(heartRateStyle: .beating(bpm: 170)))
            .frame(width: 20, height: 20, alignment: .center)

        HeartRateView(viewModel: HeartRateViewModel(heartRateStyle: .beating(bpm: 65)))
            .frame(width: 20, height: 20, alignment: .center)
    }
}
