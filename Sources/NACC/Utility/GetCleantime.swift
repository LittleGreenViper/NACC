//
//  GetCleantime.swift
//  
//
//  Created by Chris Marshall on 9/2/24.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct GetCleantime: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "GetCleantimeIntent"

    static var title: LocalizedStringResource = "Get Cleantime"
    static var description = IntentDescription("Ask the app to calculate and return the cleantime, given a cleandate.")

    @Parameter(title: "Clean Date")
    var cleanDate: DateComponents?

    static var parameterSummary: some ParameterSummary {
        Summary("Enter \(\.$cleanDate), and return the cleantime.")
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$cleanDate)) { cleanDate in
            DisplayRepresentation(
                title: "Enter \(cleanDate!), and return the cleantime.",
                subtitle: ""
            )
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // TODO: Place your refactored intent handler code here.
        return .result(value: String(/* fill in result initializer here */))
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static var cleanDateParameterPrompt: Self {
        "Please give me your clean date."
    }
    static func cleanDateParameterDisambiguationIntro(count: Int, cleanDate: DateComponents) -> Self {
        "There are \(count) options matching ‘\(cleanDate)’."
    }
    static func cleanDateParameterConfirmation(cleanDate: DateComponents) -> Self {
        "Just to confirm, you wanted ‘\(cleanDate)’?"
    }
    static var cleanDateParameterCantBeBeforeOct51953: Self {
        "You cannot enter a date before October 5th, 1953, as that is when NA started."
    }
    static func responseSuccess(cleantime: String) -> Self {
        "Your cleantime is \(cleantime)."
    }
    static var responseFailure: Self {
        "Unable to calculate cleantime from your cleandate. Sorry."
    }
}

