/*
© Copyright 2012-2024, Little Green Viper Software Development LLC

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import AppIntents
import SwiftUI
import WidgetKit

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
struct NACC_WidgetControl: ControlWidget {
    /* ################################################################## */
    /**
     */
    static let kind: String = "org.magshare.NACC.NACC Widget"

    /* ################################################################## */
    /**
     */
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value.isRunning,
                action: StartTimerIntent(value.name)
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
extension NACC_WidgetControl {
    /* ################################################################## */
    /**
     */
    struct Value {
        var isRunning: Bool
        var name: String
    }

    /* ################################################################## */
    /**
     */
    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: TimerConfiguration) -> Value {
            NACC_WidgetControl.Value(isRunning: false, name: configuration.timerName)
        }

        func currentValue(configuration: TimerConfiguration) async throws -> Value {
            let isRunning = true // Check if the timer is running
            return NACC_WidgetControl.Value(isRunning: isRunning, name: configuration.timerName)
        }
    }
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
struct TimerConfiguration: ControlConfigurationIntent {
    /* ################################################################## */
    /**
     */
    static let title: LocalizedStringResource = "Timer Name Configuration"

    /* ################################################################## */
    /**
     */
   @Parameter(title: "Timer Name", default: "Timer")
    
    /* ################################################################## */
    /**
     */
    var timerName: String
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
struct StartTimerIntent: SetValueIntent {
    /* ################################################################## */
    /**
     */
    static let title: LocalizedStringResource = "Start a timer"

    /* ################################################################## */
    /**
     */
    @Parameter(title: "Timer Name")

    /* ################################################################## */
    /**
     */
    var name: String

    /* ################################################################## */
    /**
     */
    @Parameter(title: "Timer is running")

    /* ################################################################## */
    /**
     */
    var value: Bool

    /* ################################################################## */
    /**
     */
    init() {}

    /* ################################################################## */
    /**
     */
    init(_ name: String) {
        self.name = name
    }

    /* ################################################################## */
    /**
     */
    func perform() async throws -> some IntentResult {
        // Start the timer…
        return .result()
    }
}
