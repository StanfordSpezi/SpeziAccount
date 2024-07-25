//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


// TODO: remove
/*
 case let .exactly(keys) = accountService.configuration.supportedAccountKeys
 self.serviceSupportedKeys = keys


 let modifiedDetails = splitDetails(from: modifications.modifiedDetails)
 let removedDetails = splitDetails(from: modifications.removedAccountDetails)

 private func splitDetails<Values: AccountValues>(
 from details: Values
 ) -> (service: Values, standard: Values) {
 let serviceBuilder = AccountValuesBuilder<Values>()
 let standardBuilder = AccountValuesBuilder<Values>(from: details)
 
 
 for element in serviceSupportedKeys {
 // remove all service supported keys from the standard builder (which is a copy of `details` currently)
 standardBuilder.remove(element.key)
 }
 
 // copy all values from `details` of the service supported keys into the service builder
 serviceBuilder.merging(keys: serviceSupportedKeys, from: details)
 
 return (serviceBuilder.build(), standardBuilder.build())
 }
 */
