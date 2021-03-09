//
//  InMemoryStorageTest.swift
//  Urna-iOSTests
//
//  Created by Jordi Pellat Massó on 2/11/20.
//  Copyright © 2020 Urna. All rights reserved.
//

import XCTest
import Datasources

class InMemorySingleRecordStorageTest: XCTestCase {
    
    var storage: AnySingleRecordStorage<Int>!
    
    override func setUp() {
        storage = InMemoryStorage(initialValue: 5).toAnySingleRecordStorage()
    }
    
    func test_initialValue_initialValue() {
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
    
    func test_clean_hasInitialValue() {
        storage.update(data: 3)
        storage.clean()
        
        XCTAssertEqual(storage.getData(), 5)
    }
}
