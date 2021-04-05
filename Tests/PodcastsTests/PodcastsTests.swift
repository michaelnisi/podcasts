import XCTest
@testable import Podcasts

final class PodcastsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Podcasts().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
