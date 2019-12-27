import XCTest
import PenguinParallel

final class PrefetchPipelineIteratorTests: XCTestCase {

    func testSimplePrefetch() {
        XCTAssert(PipelineIterator._allThreadsStopped())
        // Do everything in a do-block to ensure the iterator is cleaned up before
        // checking to ensure all threads have been stopped.
        do {
            var semaphores = [DispatchSemaphore]()
            semaphores.reserveCapacity(6)
            for _ in 0..<6 {
                semaphores.append(DispatchSemaphore(value: 0))
            }

            var i = 0
            let tmp: GeneratorPipelineIterator<Int> = PipelineIterator.generate {
                semaphores[i].signal()
                i += 1
                if i >= 6 { return nil }
                return 10 + i
            }
            var itr = tmp.prefetch(count: 3)
            // Wait & verify prefetching did occur!
            semaphores[0].wait()
            semaphores[1].wait()
            semaphores[2].wait()
            XCTAssertEqual(3, i)
            XCTAssertEqual(11, try! itr.next())
            semaphores[3].wait()
            XCTAssertEqual(4, i)
            XCTAssertEqual(12, try! itr.next())
            XCTAssertEqual(13, try! itr.next())
            XCTAssertEqual(14, try! itr.next())
            XCTAssertEqual(15, try! itr.next())
            XCTAssertEqual(nil, try! itr.next())
        }
        XCTAssert(PipelineIterator._allThreadsStopped())
    }

    static var allTests = [
        ("testSimplePrefetch", testSimplePrefetch),
    ]
}
