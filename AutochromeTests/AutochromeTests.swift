import XCTest
@testable import Autochrome

/// Placeholder. Replace with the cases required by SPEC.md section 17.
final class AutochromeTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: AutochromeApp.self), "AutochromeApp")
    }
}
