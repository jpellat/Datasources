//
//  MultiRecordStorga.swift
//  Datasources
//
//  Created by Jordi Pellat Massó on 2/16/20.
//

import Foundation
import Combine

public typealias ID = String

@available(watchOS 6.0, *)
public protocol Recordable: Codable, Equatable {
    var id: ID? {get set}
}

@available(watchOS 6.0, *)
public protocol MultiRecordStorage: MultiRecordDatasource {
    func save(_ data: DataType) -> DataType
    func clean() -> Void
}

@available(watchOS 6.0, *)
public extension MultiRecordStorage {
    func toAnyMultiRecordStorage() -> AnyMultiRecordStorage<DataType> {
        AnyMultiRecordStorage(self)
    }
}

@available(watchOS 6.0, *)
public struct AnyMultiRecordStorage<DT>: MultiRecordStorage where DT: Recordable {
    private let storage: Any
    private let saveFunc: (DT) -> DT
    private let queryAllFunc: () -> AnyPublisher<[DT], Never>
    private let queryFunc: (MultiRecordQuery<DT>) -> AnyPublisher<[DT], Never>
    private let cleanFunc: () -> Void
    
    init<D: MultiRecordStorage>(_ storage: D) where D.DataType == DT {
        self.storage = storage
        queryAllFunc = storage.queryAll
        saveFunc = storage.save
        queryFunc = storage.query
        cleanFunc = storage.clean
    }
    
    public func save(_ data: DT) -> DT {
        saveFunc(data)
    }
    
    public func queryAll() -> AnyPublisher<[DT], Never> {
        queryAllFunc()
    }
    
    func query(query: MultiRecordQuery<DT>) -> AnyPublisher<[DT], Never> {
        queryFunc(query)
    }
    
    public func clean() {
        cleanFunc()
    }
}
