import Foundation
import XCTest

final class CleandateSessionTests: XCTestCase {
    private func link(_ string: String) throws -> NACC_DeepLink {
        try XCTUnwrap(NACC_DeepLink(url: XCTUnwrap(URL(string: string))))
    }

    func testExistingDeepAndUniversalLinks() throws {
        for prefix in ["nacc://?", "https://nacc.littlegreenviper.com/?"] {
            for tab in [nil, 0, 1, 2] as [Int?] {
                let suffix = tab.map { "/\($0)" } ?? ""
                let parsed = try link(prefix + "2020-03-17" + suffix)
                XCTAssertEqual(parsed.tabIndex, tab)
                XCTAssertFalse(parsed.isTemporary)
                XCTAssertEqual(Calendar.current.component(.day, from: parsed.date), 17)
            }
        }
    }

    func testTemporaryDeepAndUniversalLinksWithEveryTab() throws {
        for prefix in ["nacc://?", "https://nacc.littlegreenviper.com/?"] {
            for tab in [nil, 0, 1, 2] as [Int?] {
                let suffix = tab.map { "/\($0)" } ?? ""
                let parsed = try link(prefix + "2020-03-17" + suffix + "&temp")
                XCTAssertTrue(parsed.isTemporary)
                XCTAssertEqual(parsed.tabIndex, tab)
            }
        }
        XCTAssertTrue(try link("nacc://?2020-03-17%2F1&temp=").isTemporary)
        XCTAssertTrue(try link("nacc://?2020-03-17/1&other=value&temp").isTemporary)
    }

    func testInvalidAndDatelessLinksAreIgnored() {
        for value in ["nacc://", "nacc://?", "nacc://?&temp", "nacc://?temp",
                      "nacc://?not-a-date&temp", "nacc://?2020-02-30&temp",
                      "nacc://?2020-3-17&temp", "nacc://?2020-03-17=value&temp"] {
            XCTAssertNil(NACC_DeepLink(url: URL(string: value)!), value)
        }
    }

    func testOnlySeparateTempArgumentEnablesTemporaryMode() throws {
        for suffix in ["&attempt", "&other=temp", "&temporary", "&Temp"] {
            XCTAssertFalse(try link("nacc://?2020-03-17/1" + suffix).isTemporary)
        }
    }

    func testNormalDateEditsRemainPersistent() throws {
        let ownDate = try link("nacc://?1980-09-01").date
        let newDate = try link("nacc://?1990-05-06").date
        var session = NACC_CleandateSession(savedDate: ownDate)
        XCTAssertEqual(session.dateToSave, ownDate)
        session.selectDate(newDate)
        XCTAssertEqual(session.selectedDate, newDate)
        XCTAssertEqual(session.dateToSave, newDate)
    }

    func testTemporaryDateAndPickerEditsNeverBecomePersistent() throws {
        let ownDate = try link("nacc://?1980-09-01").date
        let temporary = try link("nacc://?2020-03-17/1&temp")
        var session = NACC_CleandateSession(savedDate: ownDate)
        session.open(temporary)
        XCTAssertEqual(session.selectedDate, temporary.date)
        XCTAssertNil(session.dateToSave)
        session.selectDate(try link("nacc://?2021-04-18").date)
        XCTAssertTrue(session.isTemporary)
        XCTAssertNil(session.dateToSave)
        session.selectDate(ownDate)
        XCTAssertTrue(session.isTemporary)
        XCTAssertNil(session.dateToSave)
    }

    func testBackgroundRestoresSavedDateAndAllowsNormalEdits() throws {
        let ownDate = try link("nacc://?1980-09-01").date
        var session = NACC_CleandateSession(savedDate: ownDate)
        session.open(try link("nacc://?2020-03-17&temp"))
        session.endTemporarySession(savedDate: ownDate)
        XCTAssertFalse(session.isTemporary)
        XCTAssertEqual(session.selectedDate, ownDate)
        let edit = try link("nacc://?1990-05-06").date
        session.selectDate(edit)
        XCTAssertEqual(session.dateToSave, edit)
    }

    func testSecondTemporaryLinkAndRelaunchPreserveOwnDate() throws {
        let ownDate = try link("nacc://?1980-09-01").date
        var savedDate = ownDate
        var session = NACC_CleandateSession(savedDate: savedDate)
        for url in ["nacc://?2020-03-17/0&temp", "nacc://?2021-04-18/2&temp"] {
            let temporary = try link(url)
            session.open(temporary)
            if let permanentDate = session.dateToSave { savedDate = permanentDate }
            XCTAssertEqual(session.selectedDate, temporary.date)
            XCTAssertEqual(savedDate, ownDate)
        }
        let relaunched = NACC_CleandateSession(savedDate: savedDate)
        XCTAssertFalse(relaunched.isTemporary)
        XCTAssertEqual(relaunched.selectedDate, ownDate)
    }

    func testPermanentLinkEndsTemporaryModeEvenForSameDate() throws {
        let ownDate = try link("nacc://?1980-09-01").date
        var session = NACC_CleandateSession(savedDate: ownDate)
        session.open(try link("nacc://?2020-03-17/1&temp"))
        let permanent = try link("nacc://?2020-03-17/1")
        session.open(permanent)
        XCTAssertFalse(session.isTemporary)
        XCTAssertEqual(session.dateToSave, permanent.date)
    }

    func testWatchUpdatesStaySeparateFromTemporaryReport() throws {
        let ownDate = try link("nacc://?1980-09-01").date
        let watchDate = try link("nacc://?1990-05-06").date
        let temporary = try link("nacc://?2020-03-17&temp")
        var session = NACC_CleandateSession(savedDate: ownDate)
        session.open(temporary)
        session.receiveSavedDate(watchDate)
        XCTAssertEqual(session.selectedDate, temporary.date)
        XCTAssertNil(session.dateToSave)
        session.endTemporarySession(savedDate: watchDate)
        XCTAssertEqual(session.selectedDate, watchDate)
        session.receiveSavedDate(ownDate)
        XCTAssertEqual(session.selectedDate, ownDate)
    }
}

let suite = CleandateSessionTests.defaultTestSuite
suite.run()
guard let result = suite.testRun, 0 < result.executionCount, result.hasSucceeded else {
    exit(1)
}
