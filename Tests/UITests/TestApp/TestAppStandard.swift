//
// This source file is part of the CardinalKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CardinalKit
import SwiftUI


actor TestAppStandard: Standard, ObservableObjectProvider, ObservableObject {
    typealias BaseType = TestAppStandardBaseType
    typealias RemovalContext = TestAppStandardRemovalContext
    
    
    struct TestAppStandardBaseType: Identifiable, Sendable {
        var id: String
    }
    
    struct TestAppStandardRemovalContext: Identifiable, Sendable {
        var id: TestAppStandardBaseType.ID
    }
    
    
    func registerDataSource(_ asyncSequence: some TypedAsyncSequence<DataChange<BaseType, RemovalContext>>) {}
}
