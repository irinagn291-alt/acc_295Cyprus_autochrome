import XCTest
@testable import Autochrome

final class ReviewLaunchTests: XCTestCase {
    func testParsesReviewScreenKeys() {
        XCTAssertEqual(ReviewLaunch.screen(from: ["Autochrome", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Autochrome", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Autochrome", "-ReviewScreen", "goals"]), "goals")
        XCTAssertNil(ReviewLaunch.screen(from: ["Autochrome"]))
        XCTAssertNil(ReviewLaunch.screen(from: ["Autochrome", "-ReviewScreen"]))
    }
}
