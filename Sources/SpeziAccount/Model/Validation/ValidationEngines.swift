//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine
import OrderedCollections
import SwiftUI


private struct FailedResult<FieldIdentifier> {
    let validationEngineId: UUID
    let failedFieldIdentifier: FieldIdentifier? // we store an optional as it might be Never
}


private class RegisteredEngine<FieldIdentifier>: Identifiable {
    let engine: ValidationEngine
    // fieldIdentifier might be nil for fieldIdentifiers of type Never
    var fieldIdentifier: FieldIdentifier?
    var input: String
    var anyCancellable: AnyCancellable?

    var id: UUID {
        engine.id
    }


    init(engine: ValidationEngine, fieldIdentifier: FieldIdentifier?, input: String) {
        self.engine = engine
        self.fieldIdentifier = fieldIdentifier
        self.input = input
    }


    @MainActor
    func callAsFunction() -> FailedResult<FieldIdentifier>? {
        engine.runValidation(input: input)

        guard !engine.inputValid else {
            return nil
        }

        return FailedResult(validationEngineId: engine.id, failedFieldIdentifier: fieldIdentifier)
    }
}


/// Collect a set of ``ValidationEngine``s from a dynamic amount of subviews.
///
/// This type can be used to if you have a non-static amount of subviews for which each of them provides a
/// ``ValidationEngine`` instance you want to access from the parent view.
/// For example, this is useful when building `Form`s which dynamic amount of input fields. The parent will manage the
/// [@StateObject](https://developer.apple.com/documentation/swiftui/stateobject) and provide access to the subviews
/// using [environmentObject(_:)](https://developer.apple.com/documentation/swiftui/view/environmentobject(_:)).
/// The subviews can then use the ``SwiftUI/View/register(engine:with:for:input:)`` or ``SwiftUI/View/register(engine:with:input:)``
/// modifiers to register their ``ValidationEngine`` state with the `ValidationEngines` collection.
///
/// ### Pairing with SwiftUI `FocusState`
///
/// Apple's [FocusState](https://developer.apple.com/documentation/SwiftUI/FocusState) property wrapper can be used
/// to manage focus state of your text fields.
/// The `ValidationEngines` type is built to work well with SwiftUI's `FocusState` by tracking the `FieldIdentifier`
/// from which a failed validation came from. This can be useful to automatically set focus to the first field
/// that failed validation. To do so, you must specify the type you are using for your `FocusState` within the
/// `FieldIdentifier` generic. If you don't need this feature, there are convenience initializers that automatically
/// assign `Never`.
///
/// ### Implementation in the parent view
/// The parent view has to create and maintain an instance of `ValidationEngines`. The instance is passed
/// to all subviews as an environment object using the `environmentObject(_:)` modifier.
///
/// Below is a code example on how to implement `ValidationEngines` in the parent view.
///
/// - Note: All of the below examples show an implementation using `FocusState`. However, you can easily use
///     `ValidationEngines` without a focus state.
///
/// ```swift
/// struct MyParentView: View {
///     @FocusState var myFocusedField: String?
///     @StateObject var engines: ValidationEngines<String>()
///
///     var body: some View {
///         MySubView(_myFocusedField)
///             .environmentObject(engines)
///
///         Button("Submit", action: submit)
///     }
///
///     func submit() {
///         guard engines.validateSubviews(focusState: $myFocusedField) else {
///             // inputs are not valid, first invalid field is now in focus automatically
///             return
///         }
///
///         // process data from your subviews ...
///     }
/// }
/// ```
///
/// - Note: While the above example is completely static in the amount of subviews and the scenario could be
///     managed much simpler, the `ValidationEngines` type is purposefully built for scenarios where you
///     have a dynamic amount of subviews.
///
/// ### Implementation in the child view
/// A typically child view has to do manage two things:
/// * Maintain a ``ValidationEngine`` and continuously call it's ``ValidationEngine/submit(input:debounce:)`` method
///     when the text input changes.
/// * Run the validation engine's ``ValidationEngine/runValidation(input:)`` method one last time when the submit
///     button of the parent view is pressed.
///
/// These two parts are solved by two different components in the below code example:
/// * We use ``VerifiableTextField`` as a text view that expects a configured ``ValidationEngine`` in the environment
///     and uses that to run validation on changes in the text field and renders recovery suggestions below the text field.
/// * We use the ``SwiftUI/View/register(engine:with:for:input:)`` modifier to register our ``ValidationEngine`` with
///     the ``ValidationEngines`` object in the environment.
///
/// ```swift
/// struct MySubView: View {
///     let myFieldIdentifier = "MyField"
///
///     @EnvironmentObject var engines: ValidationEngines<String>
///     @StateObject var validation = ValidationEngine(rules: .asciiLettersOnly)
///
///     @FocusState var myFocusedField: String?
///     @State var text: String
///
///     var body: some View {
///         VerifiableTextField(text: $text)
///             .environmentObject(validation)
///             .focused($myFocusedField, equals: myFieldIdentifier)
///             .register(engine: validation, at: engines, for: myFieldIdentifier, input: text)
///     }
///
///     init(_ focusState: FocusState<String?>) {
///         _myFocusedField = focusState
///     }
/// }
/// ```
///
/// ## Using managed Validation
///
/// While we managed our ``ValidationEngine`` ourself in the above code example, we can also rely on the
/// ``SwiftUI/View/managedValidation(input:for:rules:)-5gj5g`` modifier to a) create ana manage a ``ValidationEngine``
/// and b) automatically register with a ``ValidationEngines`` object in the environment.
///
/// This simplifies the implementation as follows:
///
/// ```swift
/// struct MySubView: View {
///     let myFieldIdentifier = "MyField"
///
///     @FocusState var myFocusedField: String?
///     @State var text: String
///
///     var body: some View {
///         VerifiableTextField(text: $text)
///             .focused($myFocusedField, equals: myFieldIdentifier)
///             .managedValidation(input: text, for: myFieldIdentifier, rules: .asciiLettersOnly)
///     }
///
///     init(_ focusState: FocusState<String?>) {
///         _myFocusedField = focusState
///     }
/// }
/// ```
public class ValidationEngines<FieldIdentifier: Hashable>: ObservableObject {
    // deliberately not @Published, registered methods should not trigger an UI update
    private var storage: OrderedDictionary<UUID, RegisteredEngine<FieldIdentifier>>

    /// Reports input validity of all registered ``ValidationEngine``s.
    @MainActor public var allInputValid: Bool {
        storage.values
            .allSatisfy { $0.engine.inputValid }
    }


    /// Create a new `ValidationEngines` collection by specifying the type `FieldIdentifier` used with the `FocusState` instance.
    /// - Parameter focusStateOf: The underlying type of the `FocusState`.
    public init(focusStateOf: FieldIdentifier.Type = FieldIdentifier.self) {
        self.storage = [:]
    }

    /// Creates a new `ValidationEngines` instance without using the `FocusState` functionality.
    public convenience init() where FieldIdentifier == Never {
        self.init(focusStateOf: Never.self)
    }


    func contains(_ validation: ValidationEngine) -> Bool {
        storage[validation.id] != nil
    }

    /// Registers a new validation engine.
    ///
    /// - Important: You should make sure to guide any accesses through ``SwiftUI/View/register(engine:with:for:input:)``
    ///     or ``SwiftUI/View/register(engine:with:input:)``.
    func register(engine: ValidationEngine, field: FieldIdentifier?, input: String) -> EmptyView {
        if let registration = storage[engine.id] {
            registration.input = input // just update the input
            registration.fieldIdentifier = field // shouldn't change, but just to be save
            return EmptyView()
        }

        let registration = RegisteredEngine(engine: engine, fieldIdentifier: field, input: input)
        // hook up the stored validation engine with our objectWillChange publisher
        registration.anyCancellable = registration.engine.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }

        storage[engine.id] = registration
        return EmptyView()
    }

    /// Removes the registered validation engine.
    ///
    /// - Important: You should make sure to guide any accesses through ``SwiftUI/View/register(engine:with:for:input:)``
    ///     or ``SwiftUI/View/register(engine:with:input:)``.
    /// - Parameter engine: The ``ValidationEngine`` which was previously registered.
    func remove(engine: ValidationEngine) {
        if let value = storage.removeValue(forKey: engine.id) {
            value.anyCancellable?.cancel()
        }
    }

    @MainActor
    private func collectFailedResults() -> [FailedResult<FieldIdentifier>] {
        storage.values.compactMap { engine in
            engine()
        }
    }

    /// Run the validation engines of all your subviews
    ///
    /// - Parameter focusState: The first failed field will receive focus.
    /// - Returns: Returns `true` if all subviews reported valid data. Returns `false` if at least one
    ///     subview reported invalid data.
    @MainActor
    @discardableResult
    public func validateSubviews(focusState: FocusState<FieldIdentifier?>.Binding) -> Bool {
        let results = collectFailedResults()

        if let firstFailedField = results.first {
            if let fieldIdentifier = firstFailedField.failedFieldIdentifier {
                focusState.wrappedValue = fieldIdentifier
            }

            return false
        }

        return true
    }

    /// Run the validation engines of all your subviews without setting a focus state.
    /// - Returns: Returns `true` if all subviews reported valid data. Returns `false` if at least one
    ///     subview reported invalid data.
    @MainActor
    @discardableResult
    public func validateSubviews() -> Bool {
        collectFailedResults().isEmpty
    }
}
