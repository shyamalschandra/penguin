import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ArrayParallelSequenceTests.allTests),
        testCase(GeneratorPipelineIteratorTests.allTests),
        testCase(PrefetchBufferTests.allTests),
        testCase(PrefetchPipelineIteratorTests.allTests),
        testCase(RandomCollectionPipelineIteratorTests.allTests),
        testCase(RandomIndiciesIteratorTests.allTests),
        testCase(RangePipelineIteratorTests.allTests),
        testCase(ReduceWindowIteratorTests.allTests),
        testCase(SequencePipelineIteratorTests.allTests),
        testCase(TransformPipelineIteratorTests.allTests),
        testCase(ZipPipelineIteratorTests.allTests),
    ]
}
#endif
