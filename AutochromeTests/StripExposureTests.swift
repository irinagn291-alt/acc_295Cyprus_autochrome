import XCTest
@testable import Autochrome

final class StripExposureTests: XCTestCase {
    func testExposureValueUsesLog2() {
        let shutter = 1.0 / 125.0
        let ev = StripExposure.exposureValue(aperture: 8, shutter: shutter)
        XCTAssertEqual(ev, log2((8 * 8) / shutter), accuracy: 0.000_1)
        XCTAssertEqual(StripExposure.exposureValue(aperture: 0, shutter: shutter), 0)
        XCTAssertEqual(StripExposure.exposureValue(aperture: 8, shutter: 0), 0)
    }

    func testReciprocityAndQ10DevelopClamp() {
        let corrected = StripExposure.reciprocity(shutter: 0.5, exponent: 1.3)
        XCTAssertEqual(corrected, pow(0.5, 1.3), accuracy: 0.000_1)

        let warm = StripExposure.developSeconds(
            base: 480,
            q10: 2,
            referenceC: 20,
            bathC: 24,
            push: 2,
            stops: 1
        )
        let expected = 480 * pow(2, (20.0 - 24.0) / 10) * pow(2, 1)
        XCTAssertEqual(warm, expected, accuracy: 0.001)
        XCTAssertGreaterThanOrEqual(warm, 30)
        XCTAssertLessThanOrEqual(warm, 3600)

        XCTAssertEqual(
            StripExposure.developSeconds(base: 1, q10: 2, referenceC: 20, bathC: 20, push: 2, stops: 0),
            30
        )
        XCTAssertEqual(
            StripExposure.developSeconds(base: 4000, q10: 2, referenceC: 20, bathC: 10, push: 2, stops: 2),
            3600
        )
    }
}
