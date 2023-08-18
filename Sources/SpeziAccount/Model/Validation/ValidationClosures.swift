//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import SwiftUI


struct FailedResult<FieldIdentifier> {
    let validationEngineId: UUID
    let failedFieldIdentifier: FieldIdentifier? // we store an optional as it might be Never
}


struct ValidationClosure<FieldIdentifier> {
    let id: UUID
    private let fieldIdentifier: FieldIdentifier?
    private let validationClosure: () -> ValidationResult

    init(id: UUID, for fieldIdentifier: FieldIdentifier?, closure: @escaping () -> ValidationResult) {
        self.id = id
        self.fieldIdentifier = fieldIdentifier
        self.validationClosure = closure
    }

    func callAsFunction() -> FailedResult<FieldIdentifier>? {
        switch validationClosure() {
        case .success:
            return nil
        case .failed:
            // fieldIdentifier might be nil for fieldIdentifiers of type Never
            return FailedResult(validationEngineId: id, failedFieldIdentifier: fieldIdentifier)
        }
    }
}


/// A control structure to run input validation of registered subviews once the submit button is pressed.
///
/// This type is a `ObservableObject` that you can inject into your App's environment using `environmentObject(_:)`
/// to collect validation closures from your subviews.
///
/// ### Pairing with SwiftUI `FocusState`
///
/// The `FocusState` property wrapper can be used to manage focus state of your text fields.
/// The `ValidationClosures` type is built to work well with SwiftUI's `FocusState` by tracking the `FieldIdentifier`
/// from which a failed validation came from. This can be useful to automatically set focus to the first field
/// that failed validation. To do so, you must specify the type you are using for your `FocusState` within the
/// `FieldIdentifier` generic. If you don't need this feature, there are convenience initializers that automatically
/// assign `Never`.
///
/// - Note: All of the below examples show an implementation using `FocusState`. However, you can easily use
///     the `ValidationClosures` without a focus state.
///
/// ### Implementation in the parent view
/// The parent view has to create and maintain an instance of `ValidationClosures`. The instance is passed
/// to all subviews as an environment object using the `environmentObject(_:)` modifier.
///
/// Below is a code example on how to implement `ValidationClosures` in the parent view.
///
/// ```swift
/// struct MyParentView: View {
///     @FocusState var myFocusedField: String?
///     @StateObject var validationClosures ValidationClosures<String>()
///
///     var body: some View {
///         MySubView(_myFocusedField)
///             .environmentObject(validationClosures)
///
///         Button("Submit", action: submit)
///     }
///
///     func submit() {
///         guard validationClosures.validateSubviews(focusState: $myFocusedField) else {
///             // inputs are not valid, first invalid field is now in focus automatically
///             return
///         }
///
///         // process data from your subviews
///     }
/// }
/// ```
///
/// - Note: While the above example is completely static in the amount of subviews and the scenario could be
///     managed much simpler, the `ValidationClosures` type is purposefully built for scenarios where you
///     have a dynamic count of subviews.
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
/// * We use the ``SwiftUI/View/managedValidation(input:for:rules:)`` modifier to a) create and manage ``ValidationEngine``
///     and b) register to a ``ValidationClosures`` object in the environment.
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
///
/// ### Registering Validation Closures yourself
/// While the above section described how to easily use ``ValidationClosures`` _without using it_ (by relying on
/// the ``SwiftUI/View/managedValidation(input:for:rules:)`` modifier, this section provides a short code example how
/// you would do that yourself. This might be useful if you have to implement validation for a type that consist
/// of multiple substrings that need to be checked separately (e.g. `PersonNameComponents`).
///
/// ```swift
/// struct MySubView: View {
///     let myFieldIdentifier = "MyField"
///
///     @EnvironmentObject var closures: ValidationClosures
///     @StateObject var validation = ValidationEngine(rules: .asciiLettersOnly)
///
///     @FocusState var myFocusedField: String?
///     @State var text: String
///
///     var body: some View {
///         // the register call happens everytime the view renders
///         closures.register(running: validation, for: myFieldIdentifier, validation: onSubmission)
///
///         VerifiableTextField(text: $text)
///             .environmentObject(validation)
///             .focused($myFocusedField, equals: myFieldIdentifier)
///             .onDisappear { // this is important if your view may be removed from the parent view
///                 closures.remove(engine: validation)
///             }
///     }
///
///     init(_ focusState: FocusState<String?>) {
///         _myFocusedField = focusState
///     }
///
///     func onSubmission() -> ValidationResult {
///         validation.runValidation(input: text)
///         return validation.inputValid ? .success : .failed
///     }
/// }
/// ```
public class ValidationClosures<FieldIdentifier: Hashable>: ObservableObject {
    // deliberately now @Published, registered methods should not trigger a UI update
    private var storage: OrderedDictionary<UUID, ValidationClosure<FieldIdentifier>>

    /// Create a new `ValidationClosures` instance by specifying the type `FieldIdentifier` used with the `FocusState` instance.
    /// - Parameter focusStateOf: The underlying type of the `FocusState`.
    public init(focusStateOf: FieldIdentifier.Type = FieldIdentifier.self) {
        self.storage = [:]
    }

    /// Creates a new `ValidationClosures` instance without using the `FocusState` functionality.
    public convenience init() where FieldIdentifier == Never {
        self.init(focusStateOf: Never.self)
    }

    func register(validation: ValidationClosure<FieldIdentifier>) -> EmptyView {
        storage[validation.id] = validation
        return EmptyView()
    }

    /// Register a new validation closure.
    ///
    /// - Parameters:
    ///   - engine: The ``ValidationEngine`` to register the closure for. This is used to uniquely identify the validation closure.
    ///   - field: The field which should receive focus if the validation closure reports invalid state.
    ///   - validation: The validation closure returning a ``ValidationResult``.
    /// - Returns: A `EmptyView` such that you can easily call this method in your view body.
    @discardableResult
    public func register(
        running engine: ValidationEngine,
        for field: FieldIdentifier,
        validation: @escaping () -> ValidationResult
    ) -> EmptyView {
        register(validation: ValidationClosure(id: engine.id, for: field, closure: validation))
    }

    /// Register a new validation closure.
    /// - Parameters:
    ///   - engine: The ``ValidationEngine`` to register the closure for. This is used to uniquely identify the validation closure.
    ///   - validation: The validation closure returning a ``ValidationResult``.
    /// - Returns: A `EmptyView` such that you can easily call this method in your view body.
    @discardableResult
    public func register(running engine: ValidationEngine, validation: @escaping () -> ValidationResult) -> EmptyView
        where FieldIdentifier == Never {
        register(validation: ValidationClosure(id: engine.id, for: nil, closure: validation))
    }

    /// Removes the registered validation closure of the ``ValidationEngine``.
    /// - Parameter engine: The ``ValidationEngine`` which previously a validation closure was registered for.
    public func remove(engine: ValidationEngine) {
        storage[engine.id] = nil
    }

    /// Clear any registered closures from the storage.
    public func clear() {
        storage = [:]
    }

    private func collectFailedResults() -> [FailedResult<FieldIdentifier>] {
        storage.values.compactMap { closure in
            closure()
        }
    }

    /// Run the validation closures of all your subviews
    ///
    /// - Parameter focusState: The first failed field will receive focus.
    /// - Returns: Returns `true` if all subviews reported valid data. Returns `false` if at least one
    ///     subview reported invalid data.
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

    /// Run the validation closures of all your subviews
    /// - Returns: Returns `true` if all subviews reported valid data. Returns `false` if at least one
    ///     subview reported invalid data.
    @discardableResult
    public func validateSubviews() -> Bool where FieldIdentifier == Never {
        collectFailedResults().isEmpty
    }
}
