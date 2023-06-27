//
// Created by Andreas Bauer on 26.06.23.
//

import Foundation
import SpeziViews
import SwiftUI

extension View {
    // TODO naming is a bit off!
    public func replaceWithProcessingIndicator<Processing: View>(
        ifProcessing state: ViewState,
        @ViewBuilder with view: () -> Processing = { ProgressView() }
    ) -> some View {
        replaceWithProcessingIndicator(if: state == .processing, with: view)
    }

    public func replaceWithProcessingIndicator<Processing: View>(
        if processing: Bool,
        @ViewBuilder with view: () -> Processing = { ProgressView() }
    ) -> some View {
        self
            .opacity(processing ? 0.0 : 1.0)
            .overlay {
                if processing {
                    view()
                }
            }
    }
}
