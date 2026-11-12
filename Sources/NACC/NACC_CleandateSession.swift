/*
 © Copyright 2012-2026, Little Green Viper Software Development LLC
 
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

import Foundation

/* ###################################################################################################################################### */
// MARK: - Deep Link -
/* ###################################################################################################################################### */
/**
 Parses the existing date/tab query syntax, with an optional `&temp` flag.
 */
struct NACC_DeepLink {
    let date: Date
    let tabIndex: Int?
    let isTemporary: Bool

    init?(url: URL) {
        guard let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let dateItem = items.first,
              nil == dateItem.value
        else { return nil }

        let components = dateItem.name.split(separator: "/", omittingEmptySubsequences: false)
        let dateString = String(components[0])
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        guard let date = formatter.date(from: dateString),
              formatter.string(from: date) == dateString
        else { return nil }

        self.date = date
        self.tabIndex = 1 < components.count ? Int(components[1]) : nil
        self.isTemporary = items.dropFirst().contains { "temp" == $0.name }
    }
}

/* ###################################################################################################################################### */
// MARK: - Cleandate Session -
/* ###################################################################################################################################### */
/**
 Keeps the displayed date separate from preferences for the entire foreground session.
 Only `dateToSave` may be persisted; temporary dates and edits never leave this value type.
 */
struct NACC_CleandateSession {
    private(set) var selectedDate: Date
    private(set) var isTemporary = false

    var dateToSave: Date? { self.isTemporary ? nil : self.selectedDate }

    init(savedDate: Date) {
        self.selectedDate = savedDate
    }

    mutating func open(_ inLink: NACC_DeepLink) {
        self.isTemporary = inLink.isTemporary
        self.selectedDate = inLink.date
    }

    mutating func selectDate(_ inDate: Date) {
        self.selectedDate = inDate
    }

    mutating func receiveSavedDate(_ inDate: Date) {
        if !self.isTemporary {
            self.selectedDate = inDate
        }
    }

    mutating func endTemporarySession(savedDate inSavedDate: Date) {
        guard self.isTemporary else { return }
        self.isTemporary = false
        self.selectedDate = inSavedDate
    }
}
