//
//  PersistedMultiRecordStorageTest.swift
//  Urna-iOSTests
//
//  Created by Jordi Pellat Massó on 2/15/20.
//  Copyright © 2020 Urna. All rights reserved.
//

import XCTest
import Combine
import Datasources

class PersistedMultiRecordStorageTest: XCTestCase {

    var datasource: AnyMultiRecordStorage<TestRecord>!
    var subscription: AnyCancellable? = nil
    var currentData: [TestRecord]! = nil
    
    override func setUp() {
        datasource = PersistedMultiRecordStorage(fileName: "filename").toAnyMultiRecordStorage()
        datasource.clean()
        subscription = datasource.queryAll().sink(receiveValue: { (value) in
            self.currentData = value
        })
    }

    func test_saveRecord_returnsSameRecordWithNewID() {
        let record = TestRecord(data: "data")
        let returnedRecord = datasource.save(record)
        
        XCTAssertEqual(record.data, returnedRecord.data)
        XCTAssertNotNil(returnedRecord.id)
    }
    
    func test_saveMultipleRecord_haveDifferentID() {
        let record = TestRecord(data: "data")
        let returnedRecord1 = datasource.save(record)
        let returnedRecord2 = datasource.save(record)
        
        XCTAssertNotEqual(returnedRecord1.id, returnedRecord2.id)
    }
    
    func test_savedRecord_updateRecord_returnsRecordWithSameID() {
        let record = TestRecord(data: "data")
        var createdRecord = datasource.save(record)
        
        createdRecord.data = "New Data"
        let returnedRecord = datasource.save(createdRecord)
        
        XCTAssertEqual(createdRecord.id, returnedRecord.id)
        XCTAssertEqual(returnedRecord.data, "New Data")
    }
    
    func test_newRecord_isPublished() {
        var record = TestRecord(data: "data")
        record = datasource.save(record)
        
        XCTAssertTrue(currentData.contains(record))
    }
    
    func test_saveRecord_isPresentInOtherInstanceOfStorageWithSameFileName() {
        var record = TestRecord(data: "data")
        record = datasource.save(record)
        
        datasource = PersistedMultiRecordStorage(fileName: "filename").toAnyMultiRecordStorage()
        subscription = datasource.queryAll().sink(receiveValue: { (value) in
            self.currentData = value
        })
        
        XCTAssertTrue(currentData.contains(record))
    }
    
    func test_saveRecord_isNotPresentInOtherInstanceOfStorageWithDifferentFileName() {
        var record = TestRecord(data: "data")
        record = datasource.save(record)
        
        datasource = PersistedMultiRecordStorage(fileName: "otherFilename").toAnyMultiRecordStorage()
        subscription = datasource.queryAll().sink(receiveValue: { (value) in
            self.currentData = value
        })
        
        XCTAssertFalse(currentData.contains(record))
    }
    
    func test_createMultipleRecords_arePublishedAsAList() {
        var record = TestRecord(data: "data")
        record = datasource.save(record)
        
        var secondRecord = TestRecord(data: "Other data")
        secondRecord = datasource.save(secondRecord)
        
        XCTAssertTrue(currentData.contains(record))
        XCTAssertTrue(currentData.contains(secondRecord))
    }
    
    func test_createdRecord_updateRecord_onlyPublishesLastVersion() {
        var record = TestRecord(data: "data")
        record = datasource.save(record)
        var secondRecord = TestRecord(data: "Other data")
        secondRecord = datasource.save(secondRecord)
        
        secondRecord.data = "Changed data"
        _ = datasource.save(secondRecord)
        
        XCTAssertTrue(currentData.contains(record))
        XCTAssertTrue(currentData.contains(secondRecord))
        XCTAssertEqual(currentData.count, 2)
    }
    
    func test_query_justReturnsFilteredData() {
        var queriedData: [TestRecord] = [] as! [TestRecord]
        let token = datasource.query(query: MultiRecordQuery(filter: { (record) -> Bool in
            record.data == "search"
        })).sink { (records) in
            queriedData = records
        }
        
        var record = TestRecord(data: "data")
        record = datasource.save(record)
        
        XCTAssertFalse(queriedData.contains(record))
        
        var queriedResult = TestRecord(data: "search")
        queriedResult = datasource.save(queriedResult)
        
        XCTAssertTrue(currentData.contains(queriedResult))
        
        token.cancel()
    }
    
    func test_savedRecords_cleanData_newStorageHasNoData() {
        var record = TestRecord(data: "data")
        record = datasource.save(record)
        datasource.clean()
        
        datasource = PersistedMultiRecordStorage(fileName: "filename").toAnyMultiRecordStorage()
        subscription = datasource.queryAll().sink(receiveValue: { (value) in
            self.currentData = value
        })
        
        XCTAssertFalse(currentData.contains(record))
    }
    
    func test_savedRecord_clean_publishesEmptyList() {
        var record = TestRecord(data: "data")
        record = datasource.save(record)
        datasource.clean()
        
        XCTAssertEqual(currentData, [])
    }
    
    func test_savedRecordsDifferentInstances_dontShareIds() {
        var record = TestRecord(data: "data")
        record = datasource.save(record)
        
        datasource = PersistedMultiRecordStorage(fileName: "filename").toAnyMultiRecordStorage()
        
        var secondRecord = TestRecord(data: "Other data")
        secondRecord = datasource.save(secondRecord)
        
        XCTAssertNotEqual(record.id, secondRecord.id)
    }

}
