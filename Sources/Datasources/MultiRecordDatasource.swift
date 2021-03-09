//
//  MultiRecordDatasource.swift
//  Urna-iOS
//
//  Created by Jordi Pellat Massó on 2/14/20.
//  Copyright © 2020 Urna. All rights reserved.
//

import Foundation
import Combine

public protocol MultiRecordDatasource {
    associatedtype DataType
    
    func queryAll() -> AnyPublisher<[DataType], Never>
}

public struct MultiRecordQuery<DT> {
    let filter: (DT) -> Bool
    
    public init(filter:@escaping (DT) -> Bool) {
        self.filter = filter
    }
}

public extension MultiRecordDatasource {
    func toAnyMultiRecordDatasource() -> AnyMultiRecordDatasource<DataType> {
        AnyMultiRecordDatasource(self)
    }
    
    func query(query: MultiRecordQuery<DataType>) -> AnyPublisher<[DataType], Never> {
        queryAll().map { (registers) -> [DataType] in
            registers.filter { record -> Bool in
                query.filter(record)
            }
        }.eraseToAnyPublisher()
    }
}

public struct AnyMultiRecordDatasource<DT>: MultiRecordDatasource {
    private let datasource: Any
    private let queryAllFunc: () -> AnyPublisher<[DT], Never>
    private let queryFunc: (MultiRecordQuery<DT>) -> AnyPublisher<[DT], Never>
    
    public init<D: MultiRecordDatasource>(_ datasource: D) where D.DataType == DT {
        self.datasource = datasource
        queryAllFunc = datasource.queryAll
        queryFunc = datasource.query
    }
        
    public func queryAll() -> AnyPublisher<[DT], Never> {
        queryAllFunc()
    }
    
    public func query(query: MultiRecordQuery<DT>) -> AnyPublisher<[DT], Never> {
        queryFunc(query)
    }
}
