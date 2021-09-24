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
    associatedtype DataType : Equatable
    
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
        }.removeDuplicates {previous, current in
            return previous == current
        }.eraseToAnyPublisher()
    }
    
    func queryRegister(id: ID) -> AnyPublisher<DataType?, Never> {
        queryAll().map { registers in
            registers.first
        }.removeDuplicates { prev, actual in
            prev == actual
        }.eraseToAnyPublisher()
    }
}

@available(watchOS 6.0, *)
public struct AnyMultiRecordDatasource<DT: Equatable>: MultiRecordDatasource {
    private let datasource: Any
    private let queryAllFunc: () -> AnyPublisher<[DT], Never>
    private let queryFunc: (MultiRecordQuery<DT>) -> AnyPublisher<[DT], Never>
    private let queryRegisterFunc: (ID) -> AnyPublisher<DT?, Never>
    
    public init<D: MultiRecordDatasource>(_ datasource: D) where D.DataType == DT {
        self.datasource = datasource
        queryAllFunc = datasource.queryAll
        queryFunc = datasource.query
        queryRegisterFunc = datasource.queryRegister
    }
        
    public func queryAll() -> AnyPublisher<[DT], Never> {
        queryAllFunc()
    }
    
    public func query(query: MultiRecordQuery<DT>) -> AnyPublisher<[DT], Never> {
        queryFunc(query)
    }
    
    func queryRegister(id: ID) -> AnyPublisher<DT?, Never> {
        queryRegisterFunc(id)
    }
}
