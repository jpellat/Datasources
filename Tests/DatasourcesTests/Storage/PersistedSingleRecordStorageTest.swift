//
//  PersistedSingleRecordStorageTest.swift
//  Urna-iOSTests
//
//  Created by Jordi Pellat Massó on 2/12/20.
//  Copyright © 2020 Urna. All rights reserved.
//

import XCTest
import Datasources

class PersistedSingleRecordStorageTest: XCTestCase {

    var storage: PersistedSingleRecordStorage<Int>!
    
    override func setUp() {
        let deleter = PersistedSingleRecordStorage(fileName: "test", defaultValue: 5)
        deleter.clean()
        
        storage = PersistedSingleRecordStorage(fileName: "test", defaultValue: 5)
    }
    
    func test_initialValue_defaultValue() {
        XCTAssertEqual(storage.getData(), 5)
    }
    
    func test_init_publishesValue() {
        var value: Int? = 0
        
        let token = storage.getPublisher().sink { state in
            value = state
        }
        
        XCTAssertEqual(value, 5)
        token.cancel()
    }
    
    func test_updateValue_publishesChange() {
        var value: Int? = 0
        
        let token = storage.getPublisher().sink { state in
            value = state
        }
        
        storage.update(data: 3)
        
        XCTAssertEqual(value, 3)
        token.cancel()
    }
    
    func test_updateValue_changesData() {
        storage.update(data: 3)
        
        XCTAssertEqual(storage.getData(), 3)
    }
    
    func test_updateValue_otherInstanceProvideSameValue() {
        storage.update(data: 3)
        let otherInstance = PersistedSingleRecordStorage(fileName: "test", defaultValue: 5)
        
        XCTAssertEqual(otherInstance.getData(), 3)
    }
    
    func test_persistedData_data_isNeverDefaultValue() {
        let cancelExpectation = expectation(description: "Cancel")
        
        storage.update(data: 3)
        let otherInstance = PersistedSingleRecordStorage(fileName: "test", defaultValue: 5)
        let token = otherInstance.getPublisher().sink { (value) in
            XCTAssertNotEqual(value, 5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            token.cancel()
            cancelExpectation.fulfill()
        }
        wait(for: [cancelExpectation], timeout: 0.5)
    }
    
    func test_clean_setsToDefaultValue() {
        storage.update(data: 3)
        storage.clean()
        
        XCTAssertEqual(storage.getData(), 5)
    }

}
