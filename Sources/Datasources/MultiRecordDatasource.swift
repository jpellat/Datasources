//
//  MultiRecordDatasource.swift
//  Datasources
//
//  Created by Jordi Pellat Massó on 2/14/20.
//

import Foundation
import Combine

@available(watchOS 6.0, *)
public protocol MultiRecordDatasource {
    associatedtype DataType
    
    func queryAll() -> AnyPublisher<[DataType], Never>
}

@available(watchOS 6.0, *)
public struct MultiRecordQuery<DT> {
    let filter: (DT) -> Bool
    
    public init(filter:@escaping (DT) -> Bool) {
        self.filter = filter
    }
}

@available(watchOS 6.0, *)
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

@available(watchOS 6.0, *)
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
