//
//  InMemoryMultiRecordStorage.swift
//  Datasources
//
//  Created by Jordi Pellat Massó on 2/14/20.
//  Copyright © 2020 Urna. All rights reserved.
//

import Foundation
import Combine

public class InMemoryMultiRecordStorage<DT>: MultiRecordStorage where DT: Recordable {
    private var lastId = 0
    
    let recordsPublisher: CurrentValueSubject<[DT], Never>
    
    public init() {
        recordsPublisher = CurrentValueSubject<[DataType], Never>([])
    }
    
    public func save(_ data: DT) -> DT {
        var records = recordsPublisher.value
        var newData = data
        
        if let id = data.id {
            records.removeAll { (record) -> Bool in
                record.id == id
            }
        } else {
            lastId += 1
            newData.id = String(lastId)
        }
        
        records.append(newData)
        recordsPublisher.send(records)
        
        return newData
    }
    
    public func queryAll() -> AnyPublisher<[DT], Never> {
        recordsPublisher.eraseToAnyPublisher()
    }
    
    public func clean() {
        recordsPublisher.send([])
    }
}
