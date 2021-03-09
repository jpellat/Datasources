import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(InMemoryMultiRecordStorageTest.allTests),
        testCase(InMemorySingleRecordStorageTest.allTests),
        testCase(PersistedMultiRecordStorageTest.allTests),
        testCase(PersistedSingleRecordStorageTest.allTests),
    ]
}
#endif
