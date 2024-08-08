//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SnapshotTesting
@testable import SpeziAccount
import SwiftUI
import XCTest
import XCTSpezi


final class SnapshotTesting: XCTestCase {
    @MainActor
    func testBoolDisplayView() {
        let viewTrue = BoolDisplayView<MockBoolKey>(true)
        let viewFalse = BoolDisplayView<MockBoolKey>(false)
        let viewTrueYes = BoolDisplayView<MockBoolKey>(label: .yesNo, true)
        let viewFalseNo = BoolDisplayView<MockBoolKey>(label: .yesNo, false)

        // TODO: doesn't test accessibility?
#if os(iOS)
        assertSnapshot(of: viewTrue, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-viewTrue")
        assertSnapshot(of: viewFalse, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-viewFalse")
        assertSnapshot(of: viewTrueYes, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-viewTrueYes")
        assertSnapshot(of: viewFalseNo, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-viewFalseNo")
#endif
    }

    @MainActor
    func testIntegerDisplayView() {
        let integer = FixedWidthIntegerDisplayView<MockNumericKey>(34)
        let integerWithUnit = FixedWidthIntegerDisplayView<MockNumericKey>(34, unit: Text(verbatim: " cm"))

#if os(iOS)
        assertSnapshot(of: integer, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-integer")
        assertSnapshot(of: integerWithUnit, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-integerWithUnit")
#endif
    }

    @MainActor
    func testFloatingPointDisplayView() {
        let float = FloatingPointDisplayView<MockDoubleKey>(23.56)
        let floatWithUnit = FloatingPointDisplayView<MockDoubleKey>(223.56, unit: Text(verbatim: " cm"))

#if os(iOS)
        assertSnapshot(of: float, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-float")
        assertSnapshot(of: floatWithUnit, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-floatWithUnit")
#endif
    }

    // TODO: for string and enum as well?

    @MainActor
    func testAccountProviderViewLayout() {
        let configuration = AccountConfiguration(service: InMemoryAccountService())
        withDependencyResolution {
            configuration
        }

        let view = AccountSetupProviderView { _ in
        } signup: { _ in
        } resetPassword: { _ in
        }
            .environment(configuration.account)

        let viewSignup = view.preferredAccountSetupStyle(.signup)

#if os(iOS)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-login-variant")
        assertSnapshot(of: viewSignup, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-signup-variant")
#endif
    }
}
