import Dispatch
import XCTest

@testable
import Referencing

final class ReferencedTests: XCTestCase {

    func testIsThreadSafe() {
        let referenced = Referenced(0)
        let group = DispatchGroup()
        let iterations = 1_000_000
        DispatchQueue.concurrentPerform(iterations: iterations) {
            (_) in
            group.enter()
            defer {
                group.leave()
            }
            referenced.wrappedValue += 1
        }
        let result = group.wait(timeout: .now() + 10)
        switch result {
        case .success:
            XCTAssertEqual(referenced.wrappedValue, iterations)
        case .timedOut:
            XCTFail("Test timed out")
        }
    }

    func testPerformanceRead() {
        let referenced = Referenced(0)
        measure {
            for _ in 0 ..< 1_000_000 {
                _ = referenced.wrappedValue
            }
        }
    }

    func testPerformanceWrite() {
        let referenced = Referenced(0)
        measure {
            referenced.wrappedValue = 0
            for _ in 0 ..< 1_000_000 {
                referenced.wrappedValue += 1
            }
        }
    }
}
