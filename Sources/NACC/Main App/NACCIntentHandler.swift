/*
 © Copyright 2022, Little Green Viper Software Development LLC
 
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
// MARK: - Intent Handling Class -
/* ###################################################################################################################################### */
/**
 */
public class NACCIntentHandler: NSObject {
    /* ################################################################## */
    /**
     */
    public func resolveQuantity(for inIntent: GetCleantimeIntent, with inCompletion: @escaping (INDateComponentsResolutionResult) -> Void) {
        var result: INDateComponentsResolutionResult = INDateComponentsResolutionResult.needsValue()
        
        if let cleanDate = inIntent.cleanDate {
            if let minimumDate = Calendar.current.date(from: DateComponents(year: 1953, month: 11, day: 5)),
               let currentDate = Calendar.current.date(from: cleanDate),
               (Calendar.current.startOfDay(for: minimumDate)..<Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)).contains(currentDate) {
                result = INDateComponentsResolutionResult.success(with: cleanDate)
            } else {
                result = INDateComponentsResolutionResult.unsupported()
            }
        }
        
        inCompletion(result)
    }
    
    /* ################################################################## */
    /**
     */
    func handle(getCleantime inIntent: GetCleantimeIntent, completion: @escaping (CleantimeResponse) -> Void) {
        var result: CleantimeResponse = CleantimeResponse(cleantime: "ERROR")
        
        if let cleanDate = inIntent.cleanDate {
            if let minimumDate = Calendar.current.date(from: DateComponents(year: 1953, month: 11, day: 5)),
               let currentDate = Calendar.current.date(from: cleanDate),
               (Calendar.current.startOfDay(for: minimumDate)..<Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)).contains(currentDate),
               let text = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: currentDate, endDate: .now, calendar: Calendar.current) {
                result = CleantimeResponse(cleantime: text)
            }
        }

        completion(result)
    }
}

/* ###################################################################################################################################### */
// MARK: - Intent Response Class -
/* ###################################################################################################################################### */
/**
 */
@objc public class CleantimeResponse: INIntentResponse {
    /* ################################################################## */
    /**
     */
    @NSManaged public var cleantime: String?
    
    /* ################################################################## */
    /**
     */
    init(cleantime inCleantime: String? = nil) {
        super.init()
        cleantime = inCleantime ?? "ERROR"
    }
    
    /* ################################################################## */
    /**
     */
    required init?(coder inCoder: NSCoder) {
        super.init(coder: inCoder)
    }
}

/* ###################################################################################################################################### */
// MARK: - Intent Extension Class -
/* ###################################################################################################################################### */
/**
 */
class IntentHandler: INExtension {
    /* ################################################################## */
    /**
     */
    override func handler(for inIntent: INIntent) -> Any {
        guard inIntent is GetCleantimeIntent else { fatalError("Unhandled intent type: \(inIntent)") }
        return NACCIntentHandler()
    }
}
