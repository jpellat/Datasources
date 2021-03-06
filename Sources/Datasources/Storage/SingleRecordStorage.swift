//
//  SingleRecordStorage.swift
//  Datasources
//
//  Created by Jordi Pellat Massó on 2/16/20.
//

import Foundation
import Combine

@available(watchOS 6.0, *)
public protocol SingleRecordStorage: SingleRecordDatasource {
    associatedtype DataType
    
    func update(data: DataType?) -> Void
    func clean() -> Void
}

@available(watchOS 6.0, *)
public extension SingleRecordStorage {
    func toAnySingleRecordStorage() -> AnySingleRecordStorage<DataType> {
        AnySingleRecordStorage(self)
    }
}

@available(watchOS 6.0, *)
public struct AnySingleRecordStorage<DT>: SingleRecordStorage {
    private let storage: Any
    private let getDataFunc: () -> DT?
    private let getPublisherFunc: () -> AnyPublisher<DT?, Never>
    private let updateFunc: (DT?) -> Void
    private let cleanFunc: () -> Void

    public init<D: SingleRecordStorage>(_ storage: D) where D.DataType == DT {
        self.storage = storage
        getDataFunc = storage.getData
        getPublisherFunc = storage.getPublisher
        updateFunc = storage.update
        cleanFunc = storage.clean
    }

    public func getPublisher() -> AnyPublisher<DT?, Never> {
        getPublisherFunc()
    }

    public func getData() -> DT? {
        getDataFunc()
    }

    public func update(data: DT?) {
        updateFunc(data)
    }

    public func clean() {
        cleanFunc()
    }
}
