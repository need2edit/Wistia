import XCTest
@testable import Wistia

final class WistiaTests: XCTestCase {
    
    func testInit() {
        let wistia = Wistia(api_password: "abcd123")
        XCTAssertEqual(wistia.api_password, "abcd123")
    }

    static var allTests = [
        ("testInit", testInit),
    ]
}
