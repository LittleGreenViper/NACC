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

import Intents
import LGV_UICleantime

/* ###################################################################################################################################### */
// MARK: - Open App And Display Cleantime Intent -
/* ###################################################################################################################################### */
/**
 This intent will open the app, and set it to the given date. It always opens in the main screen.
 */
class NACCShowCleantimeIntentHandler: INExtension, ShowCleantimeIntentHandling {
    /* ################################################################## */
    /**
     This validates the cleandate. It must be a date between October 5, 1953, and now.
     
     - parameters:
        - for: The intent instance
        - with: A tail completion function, with a date resoultion.
     */
    func resolveCleandate(for inIntent: ShowCleantimeIntent, with inCompletion: @escaping (INDateComponentsResolutionResult) -> Void) {
        guard let cleanDate = inIntent.cleandate,
              let minimumDate = Calendar.current.date(from: DateComponents(year: 1953, month: 10, day: 5)),
              let currentDate = Calendar.current.date(from: cleanDate),
              (Calendar.current.startOfDay(for: minimumDate)..<Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)).contains(currentDate)
        else {
            inCompletion(INDateComponentsResolutionResult.needsValue())
            return
        }
        
        inCompletion(INDateComponentsResolutionResult.success(with: Calendar.current.dateComponents([.year, .month, .day], from: currentDate)))
    }

    /* ################################################################## */
    /**
     This actually executes the intent.
     
     - parameters:
        - intent: The intent instance
        - completion: A tail completion function, with a response, containing the text of the report.
     */
    func handle(intent inIntent: ShowCleantimeIntent, completion inCompletion: @escaping (ShowCleantimeIntentResponse) -> Void) {
        guard let cleanDate = inIntent.cleandate,
              let minimumDate = Calendar.current.date(from: DateComponents(year: 1953, month: 10, day: 5)),
              let currentDate = Calendar.current.date(from: cleanDate),
              (Calendar.current.startOfDay(for: minimumDate)..<Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)).contains(currentDate),
              let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: currentDate, endDate: .now, calendar: Calendar.current),
              !textTemp.isEmpty
        else {
            inCompletion(ShowCleantimeIntentResponse(code: ShowCleantimeIntentResponseCode.failure, userActivity: nil))
            return
        }
        
//        let response = ShowCleantimeIntentResponse(code: .success, userActivity: nil)
//        response.report = textTemp
//        
//        inCompletion(response)
    }
}
