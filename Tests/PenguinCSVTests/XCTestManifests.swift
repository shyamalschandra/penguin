import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CSVReaderTests.allTests),
        testCase(UTF8IteratorTests.allTests),
    ]
}
#endif
