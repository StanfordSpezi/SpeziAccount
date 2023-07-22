//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


// TODO move a lot of this stuff!
public struct DataEntryConfigurationKey: EnvironmentKey {
    public static var defaultValue: DataEntryConfiguration {
        // TODO log that, something was accessed wrongfully!
        DataEntryConfiguration(viewState: .constant(.idle), configuration: .init(name: "MOCK"), focusedField: FocusState(), hooks: .init())
    }
}

public class DataEntryConfiguration {
    @Binding public var viewState: ViewState

    // TODO this is currently userId-type relient! => shared repository for configurtion!
    public let serviceConfiguration: UserIdPasswordServiceConfiguration

    let focusedField: FocusState<String?> // see `AccountValueKey.Type/focusState`
    let hooks: SignupSubmitHooks

    init(
        viewState: Binding<ViewState>,
        configuration: UserIdPasswordServiceConfiguration,
        focusedField: FocusState<String?>,
        hooks: SignupSubmitHooks
    ) {
        self._viewState = viewState
        self.serviceConfiguration = configuration
        self.focusedField = focusedField
        self.hooks = hooks
    }
}

extension EnvironmentValues {
    public var dataEntryConfiguration: DataEntryConfiguration {
        get {
            self[DataEntryConfigurationKey.self]
        }
        set {
            self [DataEntryConfigurationKey.self] = newValue
        }
    }
}
